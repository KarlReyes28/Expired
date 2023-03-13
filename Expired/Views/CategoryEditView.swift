//
//  CategoryEditView.swift
//  Expired
//
//  Created by satgi on 2023-03-07.
//

import SwiftUI

struct CategoryEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
    
    @State private var selectedCategory: Category?
    @State private var title: String

    init(category: Category?) {
        if let selectedCategory = category {
            _selectedCategory = State(initialValue: selectedCategory)
            _title = State(initialValue: selectedCategory.title ?? "")
        } else {
            _title = State(initialValue: "")
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Category Info")) {
                HStack {
                    Image(systemName: "pencil")
                    TextField("Title", text: $title)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(navTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(title.isEmpty)
            }
        }
    }
    
    private var navTitle: String {
        return selectedCategory?.title ?? "Add Category"
    }
    
    private func save() {
        withAnimation {
            let now = Date()

            var updatedCategory: Category

            if selectedCategory == nil {
                updatedCategory = Category(context: viewContext)
                updatedCategory.id = UUID()
                updatedCategory.createdAt = now
            } else {
                updatedCategory = selectedCategory!
            }

            updatedCategory.title = title
            updatedCategory.updatedAt = now
            
            productStore.save(viewContext)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CategoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryEditView(category: ProductStore(PersistenceController.preview.container.viewContext).categories[0])
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
