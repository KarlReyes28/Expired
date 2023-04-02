//
//  StatusColorView.swift
//  Expired
//
//  Created by Sandeep Singh on 2023-03-31.
//

import SwiftUI

struct StatusColorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var productStore: ProductStore
    @AppStorage(APP_STORAGE_KEY_STATUS_COLOR_EXPIRED) var statusColorStringExpired: String = DEFAULT_STATUS_COLOR_STRING_EXPIRED
    @AppStorage(APP_STORAGE_KEY_STATUS_COLOR_EXPIRING_SOON) var statusColorStringExpiringSoon: String = DEFAULT_STATUS_COLOR_STRING_EXPIRING_SOON
    @AppStorage(APP_STORAGE_KEY_STATUS_COLOR_GOOD) var statusColorStringGood: String = DEFAULT_STATUS_COLOR_STRING_GOOD

    @State private var statusColorExpired: Color = INITIAL_STATUS_COLOR
    @State private var statusColorExpiringSoon: Color = INITIAL_STATUS_COLOR
    @State private var statusColorGood: Color = INITIAL_STATUS_COLOR

    var body: some View {
        List {
            ColorPicker(selection: $statusColorExpired) {
                Text("Expired")
                    .foregroundColor(statusColorExpired)
            }
            ColorPicker(selection: $statusColorExpiringSoon) {
                Text("Expiring Soon")
                    .foregroundColor(statusColorExpiringSoon)
            }
            ColorPicker(selection: $statusColorGood) {
                Text("Good")
                    .foregroundColor(statusColorGood)
            }
        }
        .navigationTitle("Status Color")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    statusColorStringExpired = Color.toString(statusColorExpired)
                    statusColorStringExpiringSoon = Color.toString(statusColorExpiringSoon)
                    statusColorStringGood = Color.toString(statusColorGood)
                    
                    // Force reload the data to apply the color changes
                    productStore.reloadData(viewContext)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear {
            statusColorExpired = Color.fromString(statusColorStringExpired)
            statusColorExpiringSoon = Color.fromString(statusColorStringExpiringSoon)
            statusColorGood = Color.fromString(statusColorStringGood)
        }
    }
}

struct StatusColorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StatusColorView()
        }
    }
}
