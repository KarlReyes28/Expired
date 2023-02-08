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
    @State private var showingDeleteAlert: Bool = false
    @State private var showingDeleteResultAlert: Bool = false
    @State private var deleteSuccess: Bool = false

    var body: some View {
        // Input here for Sandeep's part
        List {
            Section(header: Text("Archive List")) {
                Text("test")
            }

            Section(header: Text("Data Management")) {
                Group {
                    Button("Remove all products") {
                       showingDeleteAlert = true
                    }
                    .alert("Are you sure you want to remove all products? \n \n Deleting it will not be recoverable.", isPresented: $showingDeleteAlert) {
                        Button("No", role: .cancel) {
                            
                        }
                        Button("Yes", role: .destructive, action: {
                            showingSuccessAlert = productStore.deleteAll(viewContext)
                        })
                    }
                    .alert(
                        "Successfully deleted all records.",
                        isPresented: $showingSuccessAlert
                    ) {
                        Button("OK") {
                            // Handle the acknowledgement.
                        }
                    }
                }
            }
        }.listStyle(.insetGrouped)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
