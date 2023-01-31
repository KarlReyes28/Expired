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

    @State private var selectedProduct: Product?
    @State private var title: String
    @State private var memo: String
    @State private var expiryDate: Date

    init(product: Product?) {
        if let selectedProduct = product {
            _selectedProduct = State(initialValue: selectedProduct)
            _title = State(initialValue: selectedProduct.title ?? "")
            _expiryDate = State(initialValue: selectedProduct.expiryDate ?? DEFAULT_EXPIRY_DATE)
            _memo = State(initialValue: selectedProduct.memo ?? "")
        } else {
            _title = State(initialValue: "")
            _expiryDate = State(initialValue: DEFAULT_EXPIRY_DATE)
            _memo = State(initialValue: "")
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
            
            Section(header: Text("Expiry Date")) {
                HStack {
                    Image(systemName: "hourglass.bottomhalf.fill")
                    DatePicker("Expiries At", selection: $expiryDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(navTitle)
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
            // To be optimized
            if selectedProduct == nil {
                selectedProduct = Product(context: viewContext)
                selectedProduct?.id = UUID()
                selectedProduct?.category = nil
                selectedProduct?.image = nil
                selectedProduct?.archived = false
                selectedProduct?.createdAt = Date()
            }

            selectedProduct?.title = title
            selectedProduct?.expiryDate = expiryDate
            selectedProduct?.memo = memo
            selectedProduct?.updatedAt = Date()
            
            productStore.save(viewContext)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProductEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProductEditView(product: ProductStore(PersistenceController.preview.container.viewContext).products[0])
    }
}
