//
//  HomeView.swift
//  Expired
//
//  Created by satgi on 2023-01-25.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore

    @State private var selectedCategory: Category?

    var body: some View {
        NavigationView {
            ProductsView(products: $productStore.unarchivedProducts, showFilter: true)
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: ProductEditView(product: nil)) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Picker("", selection: $selectedCategory) {
                            Text("All Categories").tag(Category?(nil))
                            ForEach(productStore.categories) { category in
                                Text(category.title ?? "").tag(category as Category?)
                            }
                        }
                    }
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
