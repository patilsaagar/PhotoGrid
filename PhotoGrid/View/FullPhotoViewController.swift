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
    private var fullImageView = UIImageView()
    
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
        
        setFullImageView()
        view.addSubview(fullImageView)
        view.backgroundColor = .white
        
        if let url = URL(string: photo.downloadURL),
           let cachedImage = imageCache.image(for: url) {
            fullImageView.image = cachedImage
        }
    }
    
    private func setFullImageView() {
        fullImageView = UIImageView(frame: view.bounds)
        fullImageView.contentMode = .scaleAspectFit
        fullImageView.accessibilityIdentifier = AccessibilityConstants.fullImageView
        fullImageView.isAccessibilityElement = true
    }
}
