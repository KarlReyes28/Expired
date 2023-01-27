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
            Rectangle()
                .frame(width: 4, height: 60)
                .foregroundColor(product.statusColor())
            VStack(alignment: .leading) {
                Text(product.title ?? "")
                    .font(.headline)
                Text("\(product.expiryDate ?? Date(), formatter: productFormatter)")
                    .font(.subheadline)
                    .padding(.top, 0.5)
            }
            if let memo = product.memo {
                if !memo.isEmpty {
                    Spacer()
                    HStack {
                        Button {
                            productStore.showingMemoPopover = true
                            productStore.popoverProduct = product
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.title)
                        .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

private let productFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct ProductCell_Previews: PreviewProvider {
    static var previews: some View {
        ProductCell(product: Product())
    }
}
