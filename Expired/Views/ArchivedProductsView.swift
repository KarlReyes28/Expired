//
//  ArchivedProductsView.swift
//  Expired
//
//  Created by Sandeep Singh on 2023-02-13.
//

import SwiftUI

struct ArchivedProductsView: View {
    @EnvironmentObject var productStore: ProductStore

    var body: some View {
        ProductsView(products: productStore.archivedProducts, emptyPlaceholderText: "No archived product")
            .navigationTitle("Archived products")
    }
}

struct ArchivedProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedProductsView()
            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
    }
}
