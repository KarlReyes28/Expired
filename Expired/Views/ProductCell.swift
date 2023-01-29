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
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 2)
                HStack {
                    Image(systemName: product.isExpired() ? "hourglass.bottomhalf.fill" : "hourglass.tophalf.fill")
                        .foregroundColor(product.statusColor())
                    Text("\(product.relativeExpiryDate())")
                        .font(.subheadline)
                }
            }
            if let memo = product.memo {
                if !memo.isEmpty {
                    Spacer()
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                            .onTapGesture {
                                productStore.showingMemoPopover = true
                                productStore.popoverProduct = product
                            }
                            .accessibilityLabel("Show Memo")
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
