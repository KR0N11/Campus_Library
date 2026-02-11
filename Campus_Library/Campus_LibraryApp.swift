//
//  Campus_LibraryApp.swift
//  Campus_Library
//
//  Created by user285973 on 2/10/26.
//

import SwiftUI

@main
struct Campus_LibraryApp: App {
 
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
           let context = persistenceController.container.viewContext

            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(CampusLibraryHolder(context))
        }
    }
}
