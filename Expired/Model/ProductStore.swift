//
//  ProductStore.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI
import CoreData

class ProductStore: ObservableObject {
    @Published var categories: [Category] = []
    @Published var products: [Product] = [] {
        didSet {
            updateUnarchivedProduts()
            updateArchivedProduts()
        }
    }
    @Published var unarchivedProducts: [Product] = []
    @Published var archivedProducts : [Product] = []
    @Published var selectedProduct: Product? {
        didSet {
            // Show memo popover when a product is selected by tapping the "memo icon"
            if (selectedProduct != nil) {
                showingMemoPopover = true
            }
        }
    }
    @Published var showingMemoPopover = false {
        didSet {
            // Set selectedProduct to nil whenever popover is dismissed
            if (!showingMemoPopover) {
                selectedProduct = nil
            }
        }
    }

    init(_ context: NSManagedObjectContext) {
        reloadData(context)
    }

    func reloadData(_ context: NSManagedObjectContext) {
        categories = fetchCategories(context)
        products = fetchProducts(context)
    }

    func save(_ context: NSManagedObjectContext) -> Bool {
        var result = true

        if context.hasChanges {
            do {
                try context.save()
                reloadData(context)
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                result = false
            }
        }

        return result
    }
    
    func getCategoryById(uuid: UUID?) -> Category? {
        return categories.first { category in
            category.id == uuid
        }
    }
    
    func archiveExpiredProducts(_ context: NSManagedObjectContext) -> Bool {
        products.forEach{ product in
            if (product.isExpired) {
                product.archived = true
            }
        }
        
        return save(context)
    }

    func deleteAll(_ context: NSManagedObjectContext) -> Bool {
        var result = true

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            reloadData(context)
        } catch {
            print(error)
            result = false
        }

        return result
    }
    
    private func updateUnarchivedProduts() {
        unarchivedProducts = products.filter { !$0.archived }
    }
    
    private func updateArchivedProduts() {
        archivedProducts = products.filter { $0.archived }
    }
    
    private func queryCategories(_ context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) -> [Category] {
        do {
            let request = Category.fetchRequest()
            request.sortDescriptors = sortDescriptors
            request.predicate = predicate
            return try context.fetch(request) as [Category]
        } catch let error {
            print("Unresolved error \(error)")
        }
        
        return []
    }

    private func queryProducts(_ context: NSManagedObjectContext, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil) -> [Product] {
        do {
            let request = Product.fetchRequest()
            request.sortDescriptors = sortDescriptors
            request.predicate = predicate
            return try context.fetch(request) as [Product]
        } catch let error {
            print("Unresolved error \(error)")
        }
        
        return []
    }
    
    private func fetchCategories(_ context: NSManagedObjectContext) -> [Category] {
        let updatedDateSort = NSSortDescriptor(keyPath: \Category.updatedAt, ascending: false)
        let titleSort = NSSortDescriptor(keyPath: \Category.title, ascending: true)
        return queryCategories(context, sortDescriptors: [updatedDateSort, titleSort])
    }
    
    private func fetchProducts(_ context: NSManagedObjectContext) -> [Product] {
        let expiryDateSort = NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)
        return queryProducts(context, sortDescriptors: [expiryDateSort])
    }
}
