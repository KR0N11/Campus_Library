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
            .listStyle(.insetGrouped)
            .navigationTitle("Loan History")
            .overlay {
                if holder.loans.isEmpty {
                    ContentUnavailableView("No active loans", systemImage: "tray.and.arrow.down")
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
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.system(size: 16, weight: .bold))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(loan.book?.title ?? "Unknown Book")
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Member: \(loan.member?.name ?? "Unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Group {
                    if let returned = loan.returnedAt {
                        Text("Returned \(returned, style: .date)")
                    } else if let due = loan.dueAt {
                        Text("Due \(due, style: .date)")
                    }
                }
                .font(.caption2)
                .foregroundColor(isOverdue ? .red : .secondary)
            }
            
            Spacer()
            
            if loan.returnedAt == nil {
                Button {
                    withAnimation {
                        holder.returnLoan(loan)
                    }
                } label: {
                    Text("Return")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        if loan.returnedAt != nil { return .green }
        return isOverdue ? .red : .blue
    }
    
    private var statusIcon: String {
        if loan.returnedAt != nil { return "arrow.down.circle.fill" }
        return isOverdue ? "exclamationmark.triangle.fill" : "book.fill"
    }
}
