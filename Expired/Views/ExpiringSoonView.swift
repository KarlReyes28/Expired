//
//  ExpiringSoonView.swift
//  Expired
//
//  Created by Karl Michael Reyes on 2023-03-22.
//

import SwiftUI

struct ExpiringSoonView: View {
    //    @State private var days  = 2
    @EnvironmentObject var productStore: ProductStore
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("notifyExpirySoonDate") private var days = 2
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var notificationVM: NotificationViewModel
    
    var body: some View {
        VStack {
            Text("\(days)")
                .font(.system(size:45, weight:.bold, design: .rounded))
            Stepper("How many days would you like to be reminded of your product when it is going to be expired?", value: $days, in: 2...7)
        }
        .navigationTitle("Notification Preference")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    UserDefaults.standard.set(days, forKey: "notifyExpirySoonDate" )
                    for product in products {
                        notificationVM.updateProductNotifications(viewContext, product: product)
                    }
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    private var products: [Product] {
        
        return productStore.unarchivedProducts
        
    }
}

struct ExpiringSoonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExpiringSoonView()
        }
        
    }
}
