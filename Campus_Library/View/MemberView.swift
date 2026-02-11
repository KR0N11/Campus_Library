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
                        VStack(alignment: .leading) {
                            Text(member.name ?? "Unknown")
                                .font(.headline)
                            Text(member.email ?? "")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { holder.members[$0] }.forEach(holder.deleteMember)
                }
            }
            .navigationTitle("Members")
            .toolbar {
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "person.badge.plus")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                NavigationView {
                    Form {
                        TextField("Name", text: $newName)
                        TextField("Email", text: $newEmail)
                    }
                    .navigationTitle("New Member")
                    .toolbar {
                        Button("Save") {
                            holder.createMember(name: newName, email: newEmail)
                            newName = ""
                            newEmail = ""
                            showAddSheet = false
                        }
                        .disabled(newName.isEmpty || newEmail.isEmpty)
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
            Section("Actions") {
                Button(action: { showBorrowSheet = true }) {
                    Label("Borrow a Book", systemImage: "plus.circle.fill")
                }
                .disabled(holder.books.filter { $0.isAvailable }.isEmpty)
            }
            
            Section("Active Loans") {
                if activeLoans.isEmpty {
                    Text("No active loans").foregroundColor(.secondary)
                } else {
                    ForEach(activeLoans, id: \.self) { loan in
                        MemberLoanRow(loan: loan)
                    }
                }
            }
            
            Section("Past Loans") {
                if pastLoans.isEmpty {
                    Text("No history").foregroundColor(.secondary)
                } else {
                    ForEach(pastLoans, id: \.self) { loan in
                        MemberLoanRow(loan: loan)
                    }
                }
            }
        }
        .navigationTitle(member.name ?? "Member Details")
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
        VStack(alignment: .leading, spacing: 4) {
            Text(loan.book?.title ?? "Unknown Book")
                .font(.headline)
            
            if let returned = loan.returnedAt {
                Text("Returned: \(returned, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else {
                HStack {
                    Text("Due: \(loan.dueAt ?? Date(), style: .date)")
                    
                    Spacer()

                    Text(isOverdue ? "OVERDUE" : "Active")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isOverdue ? .red : .blue)
                }
                .font(.subheadline)
                
                Button("Return Book") {
                    holder.returnLoan(loan)
                }
                .buttonStyle(.bordered)
                .tint(.blue)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
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
                        Text(book.author ?? "").font(.caption)
                    }
                    Spacer()
                    Button("Borrow") {
                        holder.borrowBook(member: member, book: book, dueDays: 7)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Book")
            .overlay {
                if availableBooks.isEmpty {
                    ContentUnavailableView("No books available", systemImage: "books.vertical")
                }
            }
        }
    }
}
