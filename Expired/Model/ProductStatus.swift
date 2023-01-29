//
//  ProductStatus.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI

enum ProductStatus: String {
    static var allStatus: [ProductStatus] {
        return [.Expired, .ExpiringSoon, .Good]
    }
    
    case Expired = "Expired"
    case ExpiringSoon = "Expiring Soon"
    case Good = "Good"
}
