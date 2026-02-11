//
//  LoanView.swift
//  Campus_Library
//
//  Created by user285973 on 2/10/26.
//

import SwiftUI

struct LoanView: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    
    var body: some View {
        NavigationView {
            List {
                ForEach(holder.loans, id: \.self) { loan in
                    LoanRow(loan: loan)
                }
            }
            .navigationTitle("All Loans")
            .overlay {
                if holder.loans.isEmpty {
                    ContentUnavailableView("No active loans", systemImage: "tray")
                }
            }
            .onAppear {
                holder.refreshLoans()
            }
        }
    }
}

struct LoanRow: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    @ObservedObject var loan: Loan
    
    var isOverdue: Bool {
        guard let dueAt = loan.dueAt, loan.returnedAt == nil else { return false }
        return dueAt < Date()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(loan.book?.title ?? "Unknown Book")
                    .font(.headline)
                Text("Borrowed by: \(loan.member?.name ?? "Unknown")")
                    .font(.caption)
                
                if let returned = loan.returnedAt {
                    Text("Returned on \(returned, style: .date)")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {

                    Text(isOverdue ? "Overdue" : "Active")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(isOverdue ? .red : .blue)
                }
            }
            
            Spacer()
            
            if loan.returnedAt == nil {
                Button {
                    holder.returnLoan(loan)
                } label: {
                    Image(systemName: "arrow.uturn.left.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}
