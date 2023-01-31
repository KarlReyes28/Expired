//
//  ProductStore.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI
import CoreData

class ProductStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var selectedProduct: Product? {
        didSet {
            // show memo popover when a product is selected by tapping the "memo icon"
            if (selectedProduct != nil) {
                showingMemoPopover = true
            }
        }
    }
    @Published var showingMemoPopover = false {
        didSet {
            // set selectedProduct to nil whenever popover is dismissed
            if (!showingMemoPopover) {
                selectedProduct = nil
            }
        }
    }
    
    init(_ context: NSManagedObjectContext) {
        reloadProducts(context)
    }
    
    func reloadProducts(_ context: NSManagedObjectContext) {
        products = fetchProducts(context)
    }
    
    func fetchProducts(_ context: NSManagedObjectContext) -> [Product] {
        do {
            let request = Product.fetchRequest()
            request.sortDescriptors = sortOrder()
            request.predicate = predicate()
            return try context.fetch(request) as [Product]
        } catch let error {
            print("Unresolved error \(error)")
        }
        
        return []
    }
    
    private func sortOrder() -> [NSSortDescriptor] {
        let expiryDateSort = NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)
        return [expiryDateSort]
    }
    
    private func predicate() -> NSPredicate {
        return NSPredicate(format: "archived != %@", NSNumber(value: true))
    }
    
    func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                reloadProducts(context)
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

