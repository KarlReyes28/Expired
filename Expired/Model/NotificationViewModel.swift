//
//  NotificationViewModel.swift
//  Expired
//
//  Created by satgi on 2023-02-12.
//

/*
 
 Case #1: Deleting products - Cancel notifications
 Request canceling scheduled notifications (expiring-soon | expired)
 ***************************************************** -> Delete notifications from Core Data
 
 Case #2: Creating/Updating products - Update notifications
 Repeat steps in Case #1
 *********************** -> Schedule notifications (expiring-soon | expired)
 ************************************************************************ -> Save notifications to Core Data
 
 */

import SwiftUI
import CoreData

let APP_STORAGE_KEY_NOTIFY_EXPIRING_SOON_DAYS: String = "notifyExpiringSoonDays"
let DEFAULT_NOTIFY_EXPIRING_SOON_DAYS: Int = 2

class NotificationViewModel: ObservableObject {
    @Published var authorizationStatusDetermined: Bool = false
    @AppStorage(APP_STORAGE_KEY_NOTIFY_EXPIRING_SOON_DAYS) var expiringSoonDays: Int = DEFAULT_NOTIFY_EXPIRING_SOON_DAYS

    init() {
        updateAuthorizationStatus()
    }
    
    func updateAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { permission in
            var determined = false
            switch permission.authorizationStatus  {
            case .authorized, .denied, .provisional, .ephemeral:
                determined = true
            case .notDetermined:
                determined = false
            default:
                determined = false
            }
            
            DispatchQueue.main.async {
                self.authorizationStatusDetermined = determined
                
                // Request permission if authorizationStatus is undetermined
                if !self.authorizationStatusDetermined {
                    self.requestPermission()
                }
            }
        })
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.updateAuthorizationStatus()
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Fetch notifications by conditions
    func fetchNotifications(_ context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) -> [LocalNotification] {
        do {
            let request = LocalNotification.fetchRequest()
            request.sortDescriptors = sortDescriptors
            request.predicate = predicate
            return try context.fetch(request) as [LocalNotification]
        } catch {
            let error = error
            print("------ Fetch notifications error: \(error.localizedDescription)")
        }
        
        return []
    }
    
    // Delete notifications by conditions
    func deleteNotifications(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocalNotification")
        fetchRequest.predicate = predicate
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        var result = true
        
        do {
            try context.execute(batchDeleteRequest)
            print("------ Notifications deleted: \(String(describing: predicate))")
        } catch {
            let error = error
            print("------ Delete notification error: \(error.localizedDescription)")
            result = false
        }
        
        return result
    }
    
    // Update a product's notifications (expiring-soon | expired)
    func updateProductNotifications(_ context: NSManagedObjectContext, product: Product) {
        // Cancel notifications if applicable
        cancelProductNotifications(context, product: product)
        
        // Schedule the expiring-soon notification
        scheduleProductNotification(context, product: product, notificationCategory: .ExpiringSoon)
        
        // Schedule the expired notification
        scheduleProductNotification(context, product: product, notificationCategory: .Expired)
    }
    
    // Cancel notifications by conditions:
    // Step #1: Request Canceling scheduled notifications from the system
    // Step #2: Delete associated notifications from Core Data
    func cancelNotifications(_ context: NSManagedObjectContext, predicate: NSPredicate? = nil) -> Bool {
        let notifications = fetchNotifications(context, sortDescriptors: nil, predicate: predicate)
        guard notifications.count > 0 else { return true }
        let notificationRequestIds = notifications.map{$0.localNotificationRequest!}
        cancelScheduledNotificationRequests(uuids: notificationRequestIds)
        return deleteNotifications(context, predicate: predicate)
    }
    
    // Cancel a product's notifications (expiring-soon | expired)
    // Then delete notifications belong to the product via Core Data relationships
    func cancelProductNotifications(_ context: NSManagedObjectContext, product: Product) {
        let notificationList = Array(product.notifications as? Set<LocalNotification> ?? [])
        guard notificationList.count > 0 else { return }
        let notificationRequestIds = notificationList.map { notification in
            notification.localNotificationRequest!
        }
        cancelScheduledNotificationRequests(uuids: notificationRequestIds)
        product.removeFromNotifications(product.notifications!)
        save(context)
    }
    
    // Schedule a notification of a given product and its notification category (expiring-soon | expired)
    private func scheduleProductNotification(_ context: NSManagedObjectContext, product: Product, notificationCategory: NotificationCategory) {
        Task {
            var notificationDate: Date?
            var notificationContent: String = ""
            switch notificationCategory {
                case .ExpiringSoon:
                    notificationDate = product.expiringSoonDate
                    var displayedDays = "\(expiringSoonDays)"
                    let converter = NumberFormatter()
                    converter.numberStyle = .spellOut
                    if let numberString = converter.string(from: NSNumber(value: expiringSoonDays)) {
                        displayedDays = numberString
                    }
                    notificationContent = "Expiring in \(displayedDays) \(expiringSoonDays > 1 ? "days" : "day")"
                case .Expired:
                    notificationDate = product.expiryDate
                    notificationContent = "Expired"
            }
            
            guard let notificationDate = notificationDate else { return }
            guard let notificationRequestId = await scheduleNotificationRequest(title: product.title!, body: notificationContent, date: notificationDate) else { return }
            
            // Data should be posted on main thread
            DispatchQueue.main.async {
                let now = Date()
                let notification = LocalNotification(context: context)
                notification.id = UUID()
                notification.product = product
                notification.localNotificationRequest = notificationRequestId
                notification.category = notificationCategory.rawValue
                notification.createdAt = now
                notification.updatedAt = now
                self.save(context)
                print("------ Notification saved: \(String(describing: product.id?.uuidString)), \(String(describing: product.title)), \(notificationCategory.rawValue)")
            }
        }
    }
    
    // Schedule a notification request to the system
    private func scheduleNotificationRequest(title: String, body: String, date: Date) async -> UUID? {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let uuid = UUID()
        let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        do {
            try await notificationCenter.add(request)
            print("------ Notification scheduled: \(uuid.uuidString), \(date), \(title), \(body)")
            return uuid
        } catch {
            let error = error
            print("------ Schedule notification request error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Request canceling scheduled notifications from the system
    private func cancelScheduledNotificationRequests(uuids: [UUID]) {
        let uuidStrings = uuids.map { $0.uuidString }
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: uuidStrings)
        print("------ Notifications canceled: \(uuids)")
    }
    
    // Fetch notifications by product
    private func fetchProductNotifications(_ context: NSManagedObjectContext, product: Product) -> [LocalNotification] {
        let predicate = NSPredicate(format: "%K == %@", "product", product.id! as CVarArg)
        return fetchNotifications(context, sortDescriptors: nil, predicate: predicate)
    }
    
    private func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
