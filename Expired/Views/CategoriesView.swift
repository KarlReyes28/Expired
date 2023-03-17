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
    @State private var showingNotDeleteAlert: Bool = false
    @State private var showingDeleteAlert = false
    @State private var deleteIndexSet: IndexSet?
    
    var emptyPlaceholderText: String = "No category found\nPress + to add your first category!"

    var body: some View {
        NavigationView {
            List {
                ForEach(productStore.categories) { category in
                    NavigationLink {
                        CategoryEditView(category: category)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(category.title ?? "")
                                .font(.headline)
                            Text(category.products?.count ?? 0 > 0 ? "\(category.products!.count) products" : "No product")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: showDeleteAlert)
            }
            .overlay(Group {
                if productStore.categories.isEmpty {
                    Text(emptyPlaceholderText)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            })
            .alert("Are you sure you want to delete this category?", isPresented: $showingDeleteAlert) {
                Button("Maybe Later", role: .cancel) {
                    deleteIndexSet = nil
                }
                Button("Yes", role: .destructive) {
                    if let indexSet = deleteIndexSet {
                        deleteCategory(indexSet: indexSet)
                    }
                    deleteIndexSet = nil
                }
            }
            .alert("Unable To Delete", isPresented: $showingNotDeleteAlert , actions: {
                Button("OK", role: .cancel) {
                }
            }, message: {
                Text("Some products are linked to this category")
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

    private func deleteCategory(indexSet: IndexSet) {
        withAnimation {
            indexSet.map{productStore.categories[$0]}.forEach{ category in
                if category.products?.count ?? 0 > 0 {
                    showingNotDeleteAlert = true
                } else {
                   viewContext.delete(category)
                }
            }
            productStore.save(viewContext)
        }
    }

    private func showDeleteAlert(indexSet: IndexSet) {
        deleteIndexSet = indexSet
        showingDeleteAlert = true
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
