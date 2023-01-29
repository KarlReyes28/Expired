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
    @State private var hasFormError = false
    
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
            Section(header: Text("Product")) {
                HStack {
                    Text("Title")
                    Text("*")
                        .padding(.horizontal, 0)
                        .font(.headline)
                        .foregroundColor(.red)
                    TextField("Product Title", text: $title)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Memo")
                    TextField("Product Memo", text: $memo)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Expiry Date"), footer: HStack {
                Text("Fields with")
                Text("*")
                    .padding(.horizontal, 0)
                    .font(.headline)
                    .foregroundColor(.red)
                Text("are mandatory")
            }) {
                HStack {
                    DatePicker("Expiries At", selection: $expiryDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(navTitle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
            }
        }
        .alert(isPresented: $hasFormError) {
            Alert(title: Text("Input Error"), message: Text("Title can not be empty"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func navTitle() -> String {
        return selectedProduct == nil ? "Add Product" : "Edit Product"
    }
    
    private func save() {
        hasFormError = title.isEmpty
        guard !hasFormError else { return }
        
        withAnimation {
            if selectedProduct == nil {
                selectedProduct = Product(context: viewContext)
                selectedProduct?.id = UUID()
                selectedProduct?.category = nil
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
        ProductEditView(product: nil)
    }
}
