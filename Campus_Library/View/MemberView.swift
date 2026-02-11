//
//  MemberView.swift
//  Campus_Library
//
//  Created by user285973 on 2/10/26.
//

import SwiftUI

struct MemberView: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    @State private var showAddSheet = false
    @State private var newName = ""
    @State private var newEmail = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(holder.members, id: \.self) { member in
                    NavigationLink(destination: MemberDetailView(member: member)) {
                        HStack(spacing: 15) {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 45, height: 45)
                                .overlay {
                                    Text(String(member.name?.first ?? "?").uppercased())
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(member.name ?? "Unknown")
                                    .font(.headline)
                                Text(member.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { holder.members[$0] }.forEach(holder.deleteMember)
                }
            }
            .navigationTitle("Members")
            .toolbar {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.title3)
                }
            }
            .sheet(isPresented: $showAddSheet) {
                NavigationView {
                    Form {
                        Section("Personal Information") {
                            TextField("Full Name", text: $newName)
                            TextField("Email Address", text: $newEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                    }
                    .navigationTitle("New Member")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showAddSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                holder.createMember(name: newName, email: newEmail)
                                newName = ""
                                newEmail = ""
                                showAddSheet = false
                            }
                            .disabled(newName.isEmpty || newEmail.isEmpty)
                            .bold()
                        }
                    }
                }
            }
        }
    }
}

struct MemberDetailView: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    @ObservedObject var member: Member
    @State private var showBorrowSheet = false
    
    var activeLoans: [Loan] {
        let all = member.loans?.allObjects as? [Loan] ?? []
        return all.filter { $0.returnedAt == nil }
                  .sorted { ($0.borrowedAt ?? Date()) > ($1.borrowedAt ?? Date()) }
    }

    var pastLoans: [Loan] {
        let all = member.loans?.allObjects as? [Loan] ?? []
        return all.filter { $0.returnedAt != nil }
                  .sorted { ($0.returnedAt ?? Date()) > ($1.returnedAt ?? Date()) }
    }

    var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue.opacity(0.8))
                    
                    Text(member.name ?? "Member")
                        .font(.title2.bold())
                    
                    Text(member.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            .listRowBackground(Color.clear)

            Section {
                Button(action: { showBorrowSheet = true }) {
                    HStack {
                        Label("New Loan", systemImage: "book.closed.fill")
                        Spacer()
                        Image(systemName: "plus")
                            .font(.caption.bold())
                    }
                }
                .disabled(holder.books.filter { $0.isAvailable }.isEmpty)
            }

            Section("Active Loans (\(activeLoans.count))") {
                if activeLoans.isEmpty {
                    Text("No current borrowings").italic().foregroundColor(.secondary)
                } else {
                    ForEach(activeLoans, id: \.self) { loan in
                        MemberLoanRow(loan: loan)
                    }
                }
            }
            
            Section("Return History") {
                if pastLoans.isEmpty {
                    Text("No past history").italic().foregroundColor(.secondary)
                } else {
                    ForEach(pastLoans, id: \.self) { loan in
                        MemberLoanRow(loan: loan)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBorrowSheet) {
            BorrowBookSheet(member: member)
        }
    }
}

struct MemberLoanRow: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    @ObservedObject var loan: Loan
    
    var isOverdue: Bool {
        guard let dueAt = loan.dueAt, loan.returnedAt == nil else { return false }
        return dueAt < Date()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(loan.book?.title ?? "Unknown Book")
                        .font(.headline)
                    
                    if let returned = loan.returnedAt {
                        Label("Returned: \(returned, style: .date)", systemImage: "arrow.down.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Label("Due: \(loan.dueAt ?? Date(), style: .date)", systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(isOverdue ? .red : .secondary)
                    }
                }
                
                Spacer()
                
                if loan.returnedAt == nil {
                    Text(isOverdue ? "OVERDUE" : "ACTIVE")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isOverdue ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
                        .foregroundColor(isOverdue ? .red : .blue)
                        .cornerRadius(4)
                }
            }
            
            if loan.returnedAt == nil {
                Button(action: {
                    withAnimation { holder.returnLoan(loan) }
                }) {
                    Text("Return Book")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }
}

struct BorrowBookSheet: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    @Environment(\.dismiss) var dismiss
    let member: Member
    
    var availableBooks: [Book] {
        holder.books.filter { $0.isAvailable }
    }
    
    var body: some View {
        NavigationView {
            List(availableBooks, id: \.self) { book in
                HStack {
                    VStack(alignment: .leading) {
                        Text(book.title ?? "")
                            .font(.headline)
                        Text(book.author ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Select") {
                        holder.borrowBook(member: member, book: book, dueDays: 7)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Lend Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .overlay {
                if availableBooks.isEmpty {
                    ContentUnavailableView("All books are currently borrowed", systemImage: "books.vertical.fill")
                }
            }
        }
    }
}
