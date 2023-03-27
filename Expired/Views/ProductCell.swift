//
//  ProductCell.swift
//  Expired
//
//  Created by satgi on 2023-01-26.
//

import SwiftUI

struct ProductCell: View {
    @EnvironmentObject var productStore: ProductStore
    @ObservedObject var product: Product

    var body: some View {
        HStack {
            ProductImage(data: product.image, size: .small)
                .padding(.trailing, 5)
            VStack(alignment: .leading) {
                HStack {
                    Text(product.title ?? "")
                        .font(.headline)
                        .padding(.bottom, 2)
                }
                HStack {
                    Image(systemName: product.isExpired ? "hourglass.bottomhalf.fill" : "hourglass.tophalf.fill")
                    Text("\(product.relativeExpiryDate)")
                }
                .font(.subheadline)
                .foregroundColor(product.statusColor)
            }
            Spacer()
            VStack(alignment: .trailing) {
                if (product.category != nil) {
                    // Access a product's category via Core Data relationship
                    Text(product.category?.title ?? "")
                        .font(.caption2)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(3)
                        .padding(.bottom, product.hasMemo ? 4 : 0)
                }
                if product.hasMemo {
                    Image(systemName: "note.text")
                        .onTapGesture {
                            productStore.selectedProduct = product
                        }
                }
            }
        }
    }
}

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ProductCell(product: ProductStore(PersistenceController.preview.container.viewContext).products[0])
                .listRowBackground(Color.cyan)
        }
        .listStyle(GroupedListStyle())
    }
}
