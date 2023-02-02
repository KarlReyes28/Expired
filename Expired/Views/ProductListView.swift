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
            VStack (spacing: 0) {
                HStack{
                    Text("Filter by status: ")
                    Spacer()
                    Picker(selection: $selectedFilter, label: Text("Select a filter")) {
                        ForEach(ProductFilter.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                .padding(.all, 15.0)
                List(filteredProducts, id: \.self) { product in
                    ProductCell(product: product)
                }
                .listStyle(PlainListStyle())
                .overlay(Group {
                    if filteredProducts.isEmpty {
                       Text("No product found\nPress + to add your first product!")
                           .font(.subheadline)
                            .multilineTextAlignment(.center)
                           .padding()
                   }
                })
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

    var filteredProducts: [Product] {
        return productStore.products.filter { product in
            return Product().extractedFunc(product, selectedFilter: selectedFilter)
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
