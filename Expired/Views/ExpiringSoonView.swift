//
//  ExpiringSoonView.swift
//  Expired
//
//  Created by Karl Michael Reyes on 2023-03-22.
//

import SwiftUI

struct ExpiringSoonView: View {
    //    @State private var days  = 2
    @AppStorage("notifyExpirySoonDate") private var days = 2
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            Text("\(days)")
                .font(.system(size:45, weight:.bold, design: .rounded))
            Stepper("How many days would you like to be reminded of your product when it is going to be expired?", value: $days, in: 2...7)
            Button("Save") {
                UserDefaults.standard.set(days, forKey: "notifyExpirySoonDate" )
                self.presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(Capsule())
            
        }
        
    }
}

struct ExpiringSoonView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiringSoonView()
    }
}
