//
//  ImageCache.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import UIKit

class ImageCache {
    private var cache: NSCache<NSURL, UIImage> = NSCache()
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
