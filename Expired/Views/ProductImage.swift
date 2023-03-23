//
//  ProductImage.swift
//  Expired
//
//  Created by satgi on 2023-03-22.
//

import SwiftUI

enum ImageSize {
    case small
    case medium
    case large
}

struct ProductImage: View {
    var image: UIImage? = nil
    var data: Data? = nil
    var size: ImageSize = .large

    var width: CGFloat {
        var width = 40.0
        switch size {
            case .small:
                width = 60.0
            case .medium:
                width = 120.0
            case .large:
                width = 180.0
        }

        return width
    }
    
    var displayImage: UIImage {
        if let image = image {
            return image
        } else if let data = data {
            return UIImage(data: data)!
        }

        return UIImage()
    }

    var body: some View {
        Image(uiImage: displayImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: width, alignment: .center)
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 4.0))
            .clipped()
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {

        if imageOrientation == .up {
            return self
        }

        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: size.height)
                transform = transform.rotated(by: CGFloat.pi)
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.rotated(by: CGFloat.pi / 2)
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.rotated(by: CGFloat.pi / -2)
            case .up, .upMirrored:
                break
        }
        
        switch imageOrientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: size.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .up, .down, .left, .right:
                break
        }

        if let cgImage = self.cgImage, let colorSpace = cgImage.colorSpace,
           let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            ctx.concatenate(transform)
            
            switch imageOrientation {
                case .left, .leftMirrored, .right, .rightMirrored:
                    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                default:
                    ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            if let ctxImage: CGImage = ctx.makeImage() {
                return UIImage(cgImage: ctxImage)
            } else {
                return self
            }
        } else {
            return self
        }
    }
}

struct ProductImage_Previews: PreviewProvider {
    static var previews: some View {
        ProductImage()
    }
}
