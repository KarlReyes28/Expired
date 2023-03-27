//
//  ExpiringSoonView.swift
//  Expired
//
//  Created by Karl Michael Reyes on 2023-03-22.
//

import SwiftUI

struct ExpiringSoonView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var productStore: ProductStore
    @EnvironmentObject var notificationVM: NotificationViewModel
    @EnvironmentObject var notificationPreferenceVM: NotificationPreferenceViewModel
    @State private var stepperValue = 2
    @AppStorage("notifyExpiringSoonDays") var notifydays: Int = 2
    
    var body: some View {
        VStack {
            Text("\(stepperValue)")
                .font(.system(size: 45, weight: .bold, design: .rounded))
                .padding()
            Stepper("How many days would you like to be reminded of your product when it is going to be expired?", value: $stepperValue, in: 1...7)
                .padding()
        }
        .onAppear {
            if notifydays != 2 {
                stepperValue = notifydays
            }
        }
        .navigationTitle("Notification Preference")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    print(notifydays)
                    notifydays = stepperValue
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
