//
//  ProductListView.swift
//  Expired
//
//  Created by satgi on 2023-01-25.
//

import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore

    var body: some View {
        NavigationView {
            HStack {
                if filteredProducts().count > 0 {
                    List {
                        ForEach(filteredProducts()) { product in
                            ProductCell(product: product).environmentObject(productStore)
                        }
                    }
                    .listStyle(GroupedListStyle())
                } else {
                    Text("No product found\nClick + to add your first product!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationBarTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProductEditView(product: nil)
                            .environmentObject(productStore)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .popover(isPresented: $productStore.showingMemoPopover) {
                VStack {
                    Text(productStore.popoverProduct?.title ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    VStack {
                        Text(productStore.popoverProduct?.memo ?? "")
                            .font(.subheadline)
                            .padding(.top, 6)
                    }
                }
            }
        }
    }
    
    private func filteredProducts() -> [Product] {
        return productStore.products
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
