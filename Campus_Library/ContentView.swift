//
//  ContentView.swift
//  Campus_Library
//
//  Created by user285973 on 2/10/26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var holder: CampusLibraryHolder
    
    var body: some View {
        TabView {
            BookView()
                .tabItem {
                    Label("Books", systemImage: "book.fill")
                }

            MemberView()
                .tabItem {
                    Label("Members", systemImage: "person.2.fill")
                }

            LoanView()
                .tabItem {
                    Label("Loans", systemImage: "arrow.left.arrow.right")
                }
        }
        .onAppear {
            holder.refreshAll()
        }
    }
}
