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
            VStack(alignment: .leading) {
                Text(product.title ?? "")
                    .font(.headline)
                    .padding(.bottom, 2)
                HStack {
                    Image(systemName: product.isExpired ? "hourglass.bottomhalf.fill" : "hourglass.tophalf.fill")
                    Text("\(product.relativeExpiryDate)")
                }
                .font(.caption)
                .foregroundColor(product.statusColor)
            }
            Spacer()
            if let memo = product.memo {
                if !memo.isEmpty {
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
