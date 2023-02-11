//
//  PushViewModel.swift
//  Expired
//
//  Created by satgi on 2023-02-12.
//

/*

 Case #1 Creating products - Schedule push
    schedule (expiring soon/expired) push
    ************************************* -> save push to Core Data

 Case #2 Deleting products - Cancel push
    cancel scheduled (expiring soon/expired) push
    ********************************************* -> delete push from Core Data

 Case #3 Updating products - Reschedule push
    Repeat steps in Case #1
    ********************** -> Repeat steps in Case #2

*/

import SwiftUI
import CoreData

class NotificationViewModel: ObservableObject {
    @Published var authorizationStatusDetermined: Bool = false

    init() {
        updateAuthorizationStatus()
    }

    func updateAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { permission in
            switch permission.authorizationStatus  {
                case .authorized, .denied, .provisional, .ephemeral:
                    print("Decided")
                    self.authorizationStatusDetermined = true
                case .notDetermined:
                    self.authorizationStatusDetermined = false
                default:
                    self.authorizationStatusDetermined = false
            }

            if !self.authorizationStatusDetermined {
                self.requestPermission()
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

    func schedulePush(title: String, body: String, date: Date) async -> UUID? {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let uuid = UUID()
        let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        do {
            try await notificationCenter.add(request)
            print("push scheduled")
            return uuid
        } catch {
            let nsError = error as NSError
            print(nsError)
            return nil
        }
    }

    func cancelPushs(uuids: [UUID]) {
        let uuidStrings = uuids.map { $0.uuidString }
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: uuidStrings)
        print("push canceled")
    }

    func scheduleProductPushes(_ context: NSManagedObjectContext, product: Product) {
        Task {
            // Schedule expiring soon push
            guard let expiringSoonDate = product.expiringSoonDate else { return }
            async let expiringSoon = schedulePush(title: product.title!, body: "Expiring in two days", date: expiringSoonDate)
            
            let uuids = await [expiringSoon]
            uuids.enumerated().forEach { index, uuid in
                if let uuid = uuid {
                    let now = Date()
                    let push = Push(context: context)
                    push.id = UUID()
                    push.product = product.id
                    push.pushRequest = uuid
                    push.category = index == 0 ? PushCategory.ExpiringSoon.rawValue : PushCategory.Expired.rawValue
                    push.createdAt = now
                    push.updatedAt = now
                    save(context)
                    print("push saved")
                }
            }
        }
    }

    func cancelProductPushes(_ context: NSManagedObjectContext, product: Product) {
        let pushes = fetchProductPushes(context, product: product)
        guard pushes.count > 0 else { return }
        let pushRequestIds = pushes.map{$0.pushRequest!}
        cancelPushs(uuids: pushRequestIds)
    }

    func fetchProductPushes(_ context: NSManagedObjectContext, product: Product) -> [Push] {
        do {
            let request = Push.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", "product", product.id! as CVarArg)
            return try context.fetch(request) as [Push]
        } catch let error {
            print("Unresolved error \(error)")
        }

        return []
    }

    func save(_ context: NSManagedObjectContext) {
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

extension NotificationViewModel {
    static func deleteAll(_ context: NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Push")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
