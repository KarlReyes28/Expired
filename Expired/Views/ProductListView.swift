//
//  ProductListView.swift
//  Expired
//
//  Created by Sandeep Singh on 2023-02-13.
//

import SwiftUI

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
    @Binding var products: [Product]
    @State private var showingDeleteAlert = false
    @State private var deleteIndexSet: IndexSet?

    var body: some View {
        List {
            ForEach(products) { product in
                NavigationLink {
                    ProductEditView(product: product)
                } label: {
                    ProductCell(product: product)
                }
            }.onDelete(perform:showingDeleteAlert)
        }
        .listStyle(GroupedListStyle())
        .overlay(Group {
            if products.isEmpty {
                Text("No product found\nPress + to add your first product!")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        })
        .popover(isPresented: $productStore.showingMemoPopover) {
            VStack {
                Spacer()
                Text(productStore.selectedProduct?.title ?? "")
                    .font(.title)
                Text(productStore.selectedProduct?.memo ?? "")
                    .padding(.top, 2)
                Spacer()
            }
            .padding()
        }
        .alert("Are you sure you want to delete this product?", isPresented: $showingDeleteAlert) {
            Button("Maybe Later", role: .cancel) {
                deleteIndexSet = nil
            }
            Button("Yes", role: .destructive) {
                if let indexSet = deleteIndexSet {
                    deleteProducts(indexSet: indexSet)
                }
                deleteIndexSet = nil
            }
        }
    }
    
    private func deleteProducts(indexSet: IndexSet){
        withAnimation {
            indexSet.map{products[$0]}.forEach(viewContext.delete)
            productStore.save(viewContext)
        }
    }
    
    private func showingDeleteAlert(indexSet: IndexSet) {
        // update both properties for later actions
        deleteIndexSet = indexSet
        showingDeleteAlert = true
    }
}

//struct ProductListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductListView([Product])
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
//    }
//}
