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
            ProductsView(products: filteredCategoryProducts, showFilter: true)
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Picker("", selection: $selectedCategory) {
                            Text("All Categories").tag(Category?(nil))
                            ForEach(productStore.categories) { category in
                                Text(category.title ?? "").tag(category as Category?)
                            }
                        }
                        // Align the selection to the left by hiding the label:
                        // https://www.reddit.com/r/SwiftUI/comments/izfnx6/is_there_a_way_to_prevent_the_color_picker_right/
                        .labelsHidden()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: ProductEditView(product: nil)) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
    }
    
    private var filteredCategoryProducts: [Product] {
        if selectedCategory != nil {
            return productStore.unarchivedProducts.filter({$0.category?.id == selectedCategory?.id})
        } else {
            return productStore.unarchivedProducts
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
