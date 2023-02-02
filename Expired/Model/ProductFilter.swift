//
//  ProductFilter.swift
//  Expired
//
//  Created by Karl Michael Reyes on 2023-02-02.
//

import Foundation
import SwiftUI

enum ProductFilter: String, CaseIterable, Identifiable {
    
    static var allFilters: [ProductFilter] {
        return [.All, .Expired, .ExpiringSoon, .Good]
    }
    case All = "All"
    case Expired = "Expired"
    case ExpiringSoon = "Expiring Soon"
    case Good = "Good"
    var id: String {
        self.rawValue
    }
}
