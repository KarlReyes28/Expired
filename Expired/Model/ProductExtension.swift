//
//  ProductExtension.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI

extension Product {
    
    func isExpired() -> Bool {
        if let expiryDate = expiryDate {
            return Date() > expiryDate
        }
        
        return false
    }
    
    func isExpiringSoon() -> Bool {
        let now = Date()
        let twoDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: now)!
        if let expiryDate = expiryDate {
            return twoDaysLater > expiryDate && !isExpired()
        }
        
        return false
    }
    
    func isGood() -> Bool {
        return !(isExpired() || isExpiringSoon())
    }
    
    func status() -> ProductStatus {
        if isExpired() {
            return .Expired
        } else if isExpiringSoon() {
            return .ExpiringSoon
        } else {
            return .Good
        }
    }
    
    func statusColor() -> Color {
        switch status() {
        case .Expired:
            return .pink
        case .ExpiringSoon:
            return .orange
        case .Good:
            return .green
        }
    }
    
    func relativeExpiryDate() -> String {
        guard let expiryDate = expiryDate else { return "" }
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: expiryDate, relativeTo: Date())
    }
}
