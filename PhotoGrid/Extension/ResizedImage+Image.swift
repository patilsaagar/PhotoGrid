//
//  ResizedImage+Image.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import UIKit

extension UIImage {
    func resizedImage(withPercentage percentage: CGFloat) -> UIImage? {
        let imageSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContext(imageSize)
        draw(in: CGRect(origin: .zero, size: imageSize))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
