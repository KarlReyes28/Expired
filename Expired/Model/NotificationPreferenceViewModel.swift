//
//  NotificationPreferenceViewModel.swift
//  Expired
//
//  Created by Karl Michael Reyes on 2023-03-27.
//

import Foundation
import Combine
class NotificationPreferenceViewModel: ObservableObject {
    let APP_STORAGE_KEY_NOTIFY_EXPIRING_SOON_DAYS: String = "notifyExpiringSoonDays"
    let DEFAULT_NOTIFY_EXPIRING_SOON_DAYS: Int = 2
}
