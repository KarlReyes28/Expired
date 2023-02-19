//
//  ArchivedProductsListView.swift
//  Expired
//
//  Created by Sandeep Singh on 2023-02-13.
//

import SwiftUI

struct ArchivedProductsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
        var body: some View {
        NavigationView {
            ProductListView(products: $productStore.archivedProducts)
        }
        
    }
}

struct ArchivedProductsListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedProductsListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
