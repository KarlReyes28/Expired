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
    @State private var selectedFilter: ProductFilter = .All

    var body: some View {
        NavigationView {
            List {
                Picker(selection: $selectedFilter, label: Text("Filter by status")) {
                    ForEach(ProductFilter.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                ForEach(filteredProducts) { product in
                  NavigationLink {
                      ProductEditView(product: product)
                  } label: {
                      ProductCell(product: product)
                  }
                }.onDelete(perform: deleteItem)
            }
            .listStyle(GroupedListStyle())
            .overlay(Group {
                if filteredProducts.isEmpty {
                    Text("No product found\nPress + to add your first product!")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            })
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
                    Text(productStore.selectedProduct?.title ?? "")
                        .font(.title)
                    Text(productStore.selectedProduct?.memo ?? "")
                        .padding(.top, 2)
                    Spacer()
                }
                .padding()
            }
        }
    }

    private var filteredProducts: [Product] {
        switch selectedFilter {
            case .All:
                return productStore.products
            case .Expired, .ExpiringSoon, .Good:
                return productStore.products.filter{ filterProduct($0, selectedFilter) }
        }
    }
    
    private func deleteItem(index: IndexSet){
        withAnimation {
            index.map{filteredProducts[$0]}.forEach(viewContext.delete)
            productStore.save(viewContext)
        }
    }

    private func filterProduct(_ product: Product, _ selectedFilter: ProductFilter) -> Bool {
        switch selectedFilter {
            case .All:
                return true
            case .Expired:
                return product.isExpired
            case .ExpiringSoon:
                return product.isExpiringSoon
            case .Good:
                return product.isGood
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
