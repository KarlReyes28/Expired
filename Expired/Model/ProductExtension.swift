//
//  ProductExtension.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI

let APP_STORAGE_KEY_STAUS_COLOR_EXPIRED: String = "statusColorExpired"
let APP_STORAGE_KEY_STAUS_COLOR_EXPIRING_SOON: String = "statusColorExpiringSoon"
let APP_STORAGE_KEY_STAUS_COLOR_GOOD: String = "statusColorGood"

extension Product {

    var isExpired: Bool {
        if let date = expiryDate {
            return date < Date()
        }
        
        return false
    }
    
    var isExpiringSoon: Bool {
        guard let date = expiringSoonDate else { return false }
        return !isExpired && Date() > date
    }
    
    var isGood: Bool {
        return !(isExpired || isExpiringSoon)
    }
    
    var expiringSoonDate: Date? {
        @AppStorage(APP_STORAGE_KEY_NOTIFY_EXPIRING_SOON_DAYS) var expiringSoonDays: Int = DEFAULT_NOTIFY_EXPIRING_SOON_DAYS

        if let date = expiryDate {
            return Calendar.current.date(byAdding: .day, value: -expiringSoonDays, to: date)
        }
        
        return nil
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
//        @AppStorage(APP_STORAGE_KEY_STAUS_COLOR_EXPIRED) var statusColorExpired: Color = .pink
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
    
    var hasMemo: Bool {
        guard let memo = memo else { return false }
        return !memo.isEmpty
    }
}
