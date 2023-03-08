//
//  CategoriesView.swift
//  Expired
//
//  Created by satgi on 2023-03-07.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore

    @State private var showingFormAlert: Bool = false
    @State private var category: String = ""
    
    var emptyPlaceholderText: String = "No category found\nPress + to add your first category!"

    var body: some View {
        NavigationView {
            List {
                ForEach(productStore.categories) { category in
                    Text(category.title ?? "")
                }
            }
            .overlay(Group {
                if productStore.categories.isEmpty {
                    Text(emptyPlaceholderText)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            })
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        CategoryEditView(category: nil)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            CategoriesView()
                .tabItem {
                    Image(systemName: "tray.fill")
                    Text("Categories")
                }
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
