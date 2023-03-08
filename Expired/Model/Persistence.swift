//
//  Persistence.swift
//  Expired
//
//  Created by satgi on 2023-01-25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let productTitles = ["Milk: Natual or Fair Life...I don't remember. It doesn't matter.", "Banana", "Beef", "Pork", "Cake", "Egg", "Beer", "Cat Food"]
        let categoryTitles = ["Vegetable", "Fruit", "Meat", "Dairy", "Alcohol"]
        
        let now = Date()
        
        var categoryIds: [UUID] = []
        for index in 0..<categoryTitles.count {
            let category = Category(context: viewContext)
            let uuid = UUID()
            category.id = uuid
            category.title = categoryTitles[index]
            category.createdAt = now
            category.updatedAt = now
            categoryIds.append(uuid)
        }

        // Data for preview
        for index in 0..<productTitles.count {
            let product = Product(context: viewContext)
            product.id = UUID()
            product.title = productTitles[index]
            product.expiryDate = Date(timeIntervalSinceNow: 86400 * Double.random(in: -3...6))
            product.memo = Int.random(in: -1...1) > 0 ? "Memo of \(productTitles[index]), I am trying to make the memo long to test the alignment." : nil
            product.archived = false
            product.category = Int.random(in: -1...1) > 0 ? categoryIds.randomElement() : nil
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
}
