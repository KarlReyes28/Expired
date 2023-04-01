//
//  SettingView.swift
//  Expired
//
//  Created by Karl Michael Reyes on 2023-02-06.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
    @EnvironmentObject var notificationVM: NotificationViewModel

    @State private var showingArchiveAlert: Bool = false
    @State private var showingArchiveResultAlert: Bool = false
    @State private var archiveSuccess: Bool = false
    @State private var showingDeleteAlert: Bool = false
    @State private var showingDeleteResultAlert: Bool = false
    @State private var deleteSuccess: Bool = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Archive")) {
                    NavigationLink(destination: ArchivedProductsView()) {
                        Text("Archived products")
                    }
                    Button("Archive expired products") {
                        showingArchiveAlert = true
                    }
                    .foregroundColor(.red)
                    .alert("Are you sure you want to archive all expired products?", isPresented: $showingArchiveAlert, actions: {
                        Button("No", role: .cancel) { }
                        Button("Yes", role: .destructive, action: {
                            archiveSuccess = productStore.archiveExpiredProducts(viewContext)
                            showingArchiveResultAlert = true
                        })
                    })
                    .alert(archiveSuccess ? "Successfully archived all expired products" : "Archiving failure\nPlease try again", isPresented: $showingArchiveResultAlert) {
                        Button("OK", role: .cancel) {
                            archiveSuccess = false
                        }
                    }
                }
                Section(header: Text("User Configurations")){
                    NavigationLink(destination: ExpiringSoonView() ) {
                        Text("Customize expiring soon days")
                    }
                }
                Section(header: Text("Status Color")){
                    NavigationLink(destination: StatusColorView() ) {
                        Text("Customize Status Color")
                    }
                }
                Section(header: Text("Data Management")) {
                    Group {
                        Button("Delete all data") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                        .alert("Are you sure you want to delete all data?", isPresented: $showingDeleteAlert, actions: {
                            Button("No", role: .cancel) { }
                            Button("Yes", role: .destructive, action: {
                                deleteSuccess = notificationVM.cancelNotifications(viewContext) && productStore.deleteAll(viewContext)
                                showingDeleteResultAlert = true
                            })
                        }, message: {
                            Text("Deleting it will not be recoverable")
                        })
                        .alert(deleteSuccess ? "Successfully deleted all data" : "Deleting failure\nPlease try again", isPresented: $showingDeleteResultAlert) {
                            Button("OK", role: .cancel) {
                                deleteSuccess = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            SettingView()
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("Settings")
                }
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
        .environmentObject(NotificationViewModel())
    }
}
