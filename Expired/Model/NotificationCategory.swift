//
//  NotificationCategory.swift
//  Expired
//
//  Created by satgi on 2023-02-12.
//

import SwiftUI

enum NotificationCategory: String {
    static var allCategories: [NotificationCategory] {
        return [.ExpiringSoon, .Expired]
    }
    
    case ExpiringSoon = "Expiring Soon"
    case Expired = "Expired"
}

