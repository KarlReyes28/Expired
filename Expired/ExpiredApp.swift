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
            TabView {
                // 1st Tab
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                // 2nd Tab
                SettingView()
                    .tabItem {
                        Image(systemName: "gear.circle.fill")
                        Text("Settings")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(ProductStore(persistenceController.container.viewContext))
            .environmentObject(NotificationViewModel())
        }
    }
}
