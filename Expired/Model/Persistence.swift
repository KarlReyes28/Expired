//
//  Persistence.swift
//  Expired
//
//  Created by satgi on 2023-01-25.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let productTitles = ["Milk: Natual or Fair Life...I don't remember. It doesn't matter.", "Banana", "Beef", "Pork", "Cake", "Egg", "Beer", "Cat Food"]
        let categoryTitles = ["🥬 Vegetable", "🍓 Fruit", "🍖 Meat", "🥛 Dairy", "🍺 Alcohol"]
        
        let now = Date()
        
        // Categories mock data
        var categories: [Category] = []
        for index in 0..<categoryTitles.count {
            let category = Category(context: viewContext)
            category.id = UUID()
            category.title = categoryTitles[index]
            category.createdAt = now
            category.updatedAt = now
            categories.append(category)
        }

        // Products mock data
        for index in 0..<productTitles.count {
            let product = Product(context: viewContext)
            product.id = UUID()
            product.title = productTitles[index]
            product.expiryDate = Date(timeIntervalSinceNow: 86400 * Double.random(in: -3...6))
            product.memo = Int.random(in: -1...1) > 0 ? "Memo of \(productTitles[index]), I am trying to make the memo long to test the alignment." : nil
            product.archived = false
            product.category = Int.random(in: -5...9) >= 0 ? categories.randomElement() : nil
            product.image = nil
            product.createdAt = now
            product.updatedAt = now
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Expired")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func populateData(context: NSManagedObjectContext, productStore: ProductStore, notificationVM: NotificationViewModel) {
        notificationVM.cancelNotifications(context)
        productStore.deleteAll(context)

        let groups = [
            [
                "category": "🥬 Vegetable",
                "items": ["Tomato", "Potato"]
            ],
            [
                "category": "🍓 Fruit",
                "items": ["Banana", "Apple", "Lemon"]
            ],
            [
                "category": "🍖 Meat",
                "items": ["Steak"]
            ],
            [
                "category": "🥛 Dairy",
                "items": ["Milk", "Cheese"]
            ],
            [
                "category": "🍺 Alcohol",
                "items": ["Beer", "Wine"]
            ],
        ]

        let now = Date()

        for index in 0..<groups.count {
            let group = groups[index]
            let category = Category(context: context)
            category.id = UUID()
            category.title = group["category"] as? String
            category.createdAt = now
            category.updatedAt = now
            productStore.save(context)
            
            let items = group["items"] as? [String]
            for index in 0..<items!.count {
                let item = items![index]
                let product = Product(context: context)
                product.id = UUID()
                product.title = item
                product.expiryDate = Date(timeIntervalSinceNow: 86400 * Double.random(in: -3...6))
                product.memo = Int.random(in: -1...2) > 0 ? "This is the memo of \(item)" : nil
                product.archived = false
                product.category = category
                let image = UIImage(named: item.lowercased())
                product.image = image?.jpegData(compressionQuality: 1)
                product.createdAt = now
                product.updatedAt = now
                productStore.save(context)
                notificationVM.updateProductNotifications(context, product: product)
            }
        }
    }
}
