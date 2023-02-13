//
//  ProductListView.swift
//  Expired
//
//  Created by satgi on 2023-01-25.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
    @State private var selectedFilter: ProductFilter = .All
    @State private var filteredProducts: [Product] = []
    
    var body: some View {
        TabView {
            // 1st Tab
            listView
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            // 2nd Tab
            SettingView()
                .tabItem {
                    Image(systemName: "gear.circle.fill")
                    Text("Settings")
                }
        }
    }
    
    private var listView: some View {
        NavigationView {
            //start list here
            VStack {
                Picker(selection: $selectedFilter, label: Text("Filter by status")) {
                    ForEach(ProductFilter.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .onChange(of: selectedFilter) { newValue in
                    updateFilteredProducts()
                }
                ProductListView(products: $filteredProducts)
            }
            .navigationBarTitle("Products")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProductEditView(product: nil)) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                updateFilteredProducts()
            }
        }
    }

    private func updateFilteredProducts() {
        switch selectedFilter {
            case .All:
                filteredProducts = productStore.products
            case .Expired, .ExpiringSoon, .Good:
                filteredProducts = productStore.products.filter{ filterProduct($0, selectedFilter) }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
