//
//  ProductStatus.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI

enum ProductStatus: String {
    static var allStatus: [ProductStatus] {
        return [.Good,.ExpiringSoon,.Expired]
    }
    
    case Good = "Good"
    case ExpiringSoon = "Expiring Soon"
    case Expired = "Expired"
}
