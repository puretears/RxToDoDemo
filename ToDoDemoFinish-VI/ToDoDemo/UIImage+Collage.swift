//
// Created by Mars on 23/05/2017.
// Copyright (c) 2017 Mars. All rights reserved.
//

import UIKit
import Foundation

extension UIImage {
    private func fixPictureSize(newSize: CGSize) -> CGRect {
        let ratio = max(newSize.width / size.width,
                newSize.height / size.height)
        let width = size.width * ratio
        let height = size.height * ratio
        let scaledRect = CGRect(x: 0, y: 0,
                width: width, height: height)

        return scaledRect
    }
    func scale(to newSize: CGSize) -> UIImage {
        guard size != newSize else {
            return self
        }

        let scaledRect = fixPictureSize(newSize: newSize)

        UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        draw(in: scaledRect)

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    static func collage(images: [UIImage], in size: CGSize) -> UIImage {
        let rows = images.count < 3 ? 1 : 2
        let columns = Int(round(Double(images.count) / Double(rows)))
        let memoSize = CGSize(width: round(size.width / CGFloat(columns)),
                height: round(size.height) / CGFloat(rows))

        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)

        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        for (index, image) in images.enumerated() {
            let drawAtX = CGFloat(index % columns) * memoSize.width
            let drawAtY = CGFloat(index / columns) * memoSize.height

            image.scale(to: memoSize).draw(at: CGPoint(x: drawAtX, y: drawAtY))
        }

        let memoImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return memoImage ?? UIImage()
    }

    static func isEqual (lhs: UIImage, rhs: UIImage) -> Bool {
        guard let data1 = UIImagePNGRepresentation(lhs),
              let data2 = UIImagePNGRepresentation(rhs) else {
            return false
        }

        return data1 == data2
    }
}
