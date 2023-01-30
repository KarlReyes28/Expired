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
                    Image(systemName: product.isExpired() ? "hourglass.bottomhalf.fill" : "hourglass.tophalf.fill")
                    Text("\(product.relativeExpiryDate())")
                }
                .font(.caption)
                .foregroundColor(product.statusColor())
            }
            if let memo = product.memo {
                if !memo.isEmpty {
                    Spacer()
                    HStack {
                        Image(systemName: "info.circle")
                            .onTapGesture {
                                productStore.showingMemoPopover = true
                                productStore.popoverProduct = product
                            }
                    }
                }
            }
        }
    }
}

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        ProductCell(product: Product())
    }
}
