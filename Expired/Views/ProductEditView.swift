//
//  ProductEditView.swift
//  Expired
//
//  Created by satgi on 2023-01-25.
//

import SwiftUI

// Default Expiry Date: 2 weeks later
let DEFAULT_EXPIRY_DATE = Date(timeIntervalSinceNow: 86400 * 14)

struct ProductEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
    @EnvironmentObject var notificationVM: NotificationViewModel

    @State private var selectedProduct: Product?
    @State private var title: String
    @State private var category: Category?
    @State private var memo: String
    @State private var expiryDate: Date

    init(product: Product?) {
        if let selectedProduct = product {
            _selectedProduct = State(initialValue: selectedProduct)
            _title = State(initialValue: selectedProduct.title ?? "")
            _memo = State(initialValue: selectedProduct.memo ?? "")
            _category = State(initialValue: selectedProduct.category)
            _expiryDate = State(initialValue: selectedProduct.expiryDate ?? DEFAULT_EXPIRY_DATE)
        } else {
            _title = State(initialValue: "")
            _memo = State(initialValue: "")
            _category = State(initialValue: nil)
            _expiryDate = State(initialValue: DEFAULT_EXPIRY_DATE)
        }
    }

    var body: some View {
        List {
            Section(header: Text("Product Info")) {
                HStack {
                    Image(systemName: "pencil")
                    TextField("Title", text: $title)
                }
                HStack {
                    Image(systemName: "note.text")
                    TextField("Memo", text: $memo)
                }
            }
            
            Section(header: Text("Category")) {
                HStack {
                    Image(systemName: "tray.fill")
                    Picker("Category", selection: $category) {
                        Text("None").tag(Category?(nil))
                        ForEach(productStore.categories) { category in
                            Text(category.title ?? "Unknown").tag(category as Category?)
                        }
                    }
                }
            }
            
            Section(header: Text("Expiry Date")) {
                HStack {
                    Image(systemName: "hourglass.tophalf.fill")
                    DatePicker("Expiries At", selection: $expiryDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(navTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(title.isEmpty)
            }
        }
    }
    
    private var navTitle: String {
        return selectedProduct?.title ?? "Add Product"
    }
    
    private func save() {
        withAnimation {
            let now = Date()

            // To be optimized
            var updatedProduct: Product

            if selectedProduct == nil {
                updatedProduct = Product(context: viewContext)
                updatedProduct.id = UUID()
                updatedProduct.category = nil
                updatedProduct.image = nil
                updatedProduct.archived = false
                updatedProduct.createdAt = now
            } else {
                updatedProduct = selectedProduct!

                // If the existed product was archived and its new expiryDate is later from now
                // Reset the its archived value to false (unarchive it)
                if updatedProduct.archived && expiryDate > Date() {
                    updatedProduct.archived = false
                }
            }

            updatedProduct.category = category
            updatedProduct.title = title
            updatedProduct.expiryDate = expiryDate
            updatedProduct.memo = memo
            updatedProduct.updatedAt = now

            productStore.save(viewContext)
            notificationVM.updateProductNotifications(viewContext, product: updatedProduct)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProductEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProductEditView(product: ProductStore(PersistenceController.preview.container.viewContext).products[0])
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
        .environmentObject(NotificationViewModel())
    }
}
