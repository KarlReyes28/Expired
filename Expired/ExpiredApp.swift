//
//  ExpiredApp.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI

@main
struct ExpiredApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProductListView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(ProductStore(persistenceController.container.viewContext))
            }
        }
    }
}
