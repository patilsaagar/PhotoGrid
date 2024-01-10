//
//  FullPhotoViewController.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import UIKit

class FullPhotoViewController: UIViewController {

    private let photo: Photo
    private let imageCache: ImageCache
    private var imageView = UIImageView()
    
    init(photo: Photo, imageCache: ImageCache) {
        self.photo = photo
        self.imageCache = imageCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(ViewControllerInitializationErrorConstants.error)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        view.backgroundColor = .white
        
        if let url = URL(string: photo.downloadURL),
           let cachedImage = imageCache.image(for: url) {
            imageView.image = cachedImage
        }
    }
}
