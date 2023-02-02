//
//  ProductExtension.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI

extension Product {
    
    var isExpired: Bool {
        if let date = expiryDate {
            return date < Date()
        }
        
        return false
    }
    
    var isExpiringSoon: Bool {
        let now = Date()
        let twoDaysLater = Calendar.current.date(byAdding: .day, value: 2, to: now)!
        if let date = expiryDate {
            return !isExpired && date < twoDaysLater
        }
        
        return false
    }
    
    var isGood: Bool {
        return !(isExpired || isExpiringSoon)
    }
    
    var status: ProductStatus {
        if isExpired {
            return .Expired
        } else if isExpiringSoon {
            return .ExpiringSoon
        } else {
            return .Good
        }
    }
    
    var statusColor: Color {
        switch status {
        case .Expired:
            return .pink
        case .ExpiringSoon:
            return .orange
        case .Good:
            return .green
        }
    }
    
    var relativeExpiryDate: String {
        guard let date = expiryDate else { return "" }
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
