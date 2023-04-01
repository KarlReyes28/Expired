//
//  ColorExtension.swift
//  Expired
//
//  Created by satgi on 2023-03-31.
//

import SwiftUI

let APP_STORAGE_KEY_STATUS_COLOR_EXPIRED: String = "statusColorExpired"
let APP_STORAGE_KEY_STATUS_COLOR_EXPIRING_SOON: String = "statusColorExpiringSoon"
let APP_STORAGE_KEY_STATUS_COLOR_GOOD: String = "statusColorGood"

// Color string pre-converted from .pink, .orange, .green
let DEFAULT_STATUS_COLOR_STRING_EXPIRED: String = "0.9999999403953552,0.1764705777168274,0.3333333134651184,1.0"
let DEFAULT_STATUS_COLOR_STRING_EXPIRING_SOON: String = "0.9999999403953552,0.5843137502670288,0.0,1.0"
let DEFAULT_STATUS_COLOR_STRING_GOOD: String = "0.20392152667045593,0.7803921699523926,0.3490195870399475,1.0"

let INITIAL_STATUS_COLOR: Color = .white

extension Color {
    static func toString(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "\(red),\(green),\(blue),\(alpha)"
    }

    static func fromString(_ colorString: String) -> Color {
        var reqColor: Color = INITIAL_STATUS_COLOR
        if (colorString != "") {
            let rgbArray = colorString.components(separatedBy: ",")
            if let red = Double(rgbArray[0]),
               let green = Double(rgbArray[1]),
               let blue = Double(rgbArray[2]),
               let alpha = Double(rgbArray[3]) {
                reqColor = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            }
        }
        return reqColor
    }
}
