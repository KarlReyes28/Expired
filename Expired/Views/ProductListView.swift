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
                if filteredProducts.count > 0 {
                    List {
                        ForEach(filteredProducts) { product in
                            ProductCell(product: product)
                        }
                    }
                    .listStyle(GroupedListStyle())
                } else {
                    Text("No product found\nPress + to add your first product!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .navigationBarTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProductEditView(product: nil)) {
                            Image(systemName: "plus")
                        }
                }
            }
            .popover(isPresented: $productStore.showingMemoPopover) {
                VStack {
                    Spacer()
                    Text(productStore.popoverProduct?.title ?? "")
                        .font(.title)
                    Text(productStore.popoverProduct?.memo ?? "")
                        .padding(.top, 2)
                    Spacer()
                }
                .padding()
            }
        }
    }

    private var filteredProducts: [Product] {
        return productStore.products
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
