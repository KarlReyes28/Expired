//
//  ProductsView.swift
//  Expired
//
//  Created by Sandeep Singh on 2023-02-13.
//

import SwiftUI

struct ProductsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var productStore: ProductStore
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    var products: [Product]
    @State private var selectedFilter: ProductFilter = .All
    @State private var showingDeleteAlert = false
    @State private var deleteIndexSet: IndexSet?
    
    var showFilter: Bool = false
    var emptyPlaceholderText: String = "No product found\nPress + to add your first product!"
    
    var body: some View {
        List {
            // Move filter picker here to avoid changing the UI
            if showFilter {
                Picker("Filter by status", selection: $selectedFilter) {
                    ForEach(ProductFilter.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
            }
            ForEach(filteredProducts) { product in
                NavigationLink {
                    ProductEditView(product: product)
                } label: {
                    ProductCell(product: product)
                }
            }
            .onDelete(perform: showDeleteAlert)
            if showFilter {
                VStack{
                    HStack (alignment: .center, spacing: 50){
                        if(selectedFilter == .All || selectedFilter == .Expired) {
                            VStack{
                                Text(ProductStatus.Expired.rawValue)
                                Text("\(expiredProductsCount)")
                            }
                        }
                        if(selectedFilter == .All || selectedFilter == .ExpiringSoon) {
                            VStack{
                                Text(ProductStatus.ExpiringSoon.rawValue)
                                Text("\(almostExpiredProductsCount)")
                            }
                        }
                        if(selectedFilter == .All || selectedFilter == .Good) {
                            VStack{
                                Text(ProductStatus.Good.rawValue)
                                Text("\(goodProductsCount)")
                            }
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
        }
        .listStyle(GroupedListStyle())
        .overlay(Group {
            if products.isEmpty {
                Text(emptyPlaceholderText)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        })
        .popover(isPresented: $productStore.showingMemoPopover) {
            VStack {
                Spacer()
                Text(productStore.selectedProduct?.title ?? "")
                    .font(.title)
                if productStore.selectedProduct != nil && productStore.selectedProduct!.image != nil {
                    ProductImage(data: productStore.selectedProduct!.image, size: .ultraLarge)
                        .padding(.vertical, 12)
                }
                Text(productStore.selectedProduct?.memo ?? "")
                    .padding(.top, 2)
                Spacer()
            }
            .padding()
        }
        .alert("Are you sure you want to delete this product?", isPresented: $showingDeleteAlert) {
            Button("Maybe Later", role: .cancel) {
                deleteIndexSet = nil
            }
            Button("Yes", role: .destructive) {
                if let indexSet = deleteIndexSet {
                    deleteProducts(indexSet: indexSet)
                }
                deleteIndexSet = nil
            }
        }
    }
    
    var expiredProductsCount: Int{
        return products.filter{
            filterProduct($0, .Expired)
        }.count
    }
    
    var almostExpiredProductsCount: Int{
        return products.filter{
            filterProduct($0, .ExpiringSoon)
        }.count
    }
    
    var goodProductsCount: Int{
        return products.filter{
            filterProduct($0, .Good)
        }.count
    }
    
    var filteredProducts: [Product] {
        switch selectedFilter {
        case .All:
            return products
        case .Expired, .ExpiringSoon, .Good:
            return products.filter{ filterProduct($0, selectedFilter)
            }
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
    
    private func deleteProducts(indexSet: IndexSet){
        withAnimation {
            indexSet.map{products[$0]}.forEach { product in
                notificationViewModel.cancelProductNotifications(viewContext, product: product)
                viewContext.delete(product)
            }
            productStore.save(viewContext)
        }
    }
    
    private func showDeleteAlert(indexSet: IndexSet) {
        // Update both properties for later actions
        deleteIndexSet = indexSet
        showingDeleteAlert = true
    }
}

struct ProductsView_Previews: PreviewProvider {
    static var previews: some View {
        ProductsView(products: ProductStore(PersistenceController.preview.container.viewContext).products)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(ProductStore(PersistenceController.preview.container.viewContext))
            .environmentObject(NotificationViewModel())
    }
}
