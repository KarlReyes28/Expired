//
//  StatusColorView.swift
//  Expired
//
//  Created by Sandeep Singh on 2023-03-31.
//

import SwiftUI

struct StatusColorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @AppStorage(APP_STORAGE_KEY_STAUS_COLOR_EXPIRED) var statusColorExpired: String = "red"
    @AppStorage(APP_STORAGE_KEY_STAUS_COLOR_EXPIRING_SOON) var statusColorExpiringSoon: String = "blue"
    @AppStorage(APP_STORAGE_KEY_STAUS_COLOR_GOOD) var statusColorGood: String = "green"
    
    @State private var localStatusColorExpired: Color = .red
    @State private var localStatusColorExpiringSoon: Color = .orange
    @State private var localStatusColorGood: Color = .green
    
    var body: some View {
        List{
            Section(header: Text("Expired")) {
                ColorPicker("Set the color", selection: $localStatusColorExpired) // COLOR
            }
            Section(header: Text("Expiring Soon")) {
                ColorPicker("Set the color", selection: $localStatusColorExpiringSoon)
            }
            Section(header: Text("Good")) {
                ColorPicker("Set the color", selection: $localStatusColorGood)
            }
        }
        .navigationTitle("Status Color")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    statusColorExpired = updateCardColorInAppStorage(color: localStatusColorExpired)
                    statusColorExpiringSoon = updateCardColorInAppStorage(color: localStatusColorExpiringSoon)
                    statusColorGood = updateCardColorInAppStorage(color: localStatusColorGood)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear {
            localStatusColorExpired = stringToColor(color: statusColorExpired)
            localStatusColorExpiringSoon = stringToColor(color: statusColorExpiringSoon)
            localStatusColorGood = stringToColor(color: statusColorGood)
        }
    }
    
    func updateCardColorInAppStorage(color: Color)-> String {
        
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return "\(red),\(green),\(blue),\(alpha)"
    }
    
    func stringToColor(color: String) -> Color {
        var reqColor : Color = .orange
        if (color != "" ) {
            let rgbArray = color.components(separatedBy: ",")
            if let red = Double (rgbArray[0]), let green = Double (rgbArray[1]), let blue = Double(rgbArray[2]), let alpha = Double (rgbArray[3]){ reqColor = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            }
        }
        return reqColor
        }
}

struct StatusColorView_Previews: PreviewProvider {
    static var previews: some View {
        StatusColorView()
    }
}
