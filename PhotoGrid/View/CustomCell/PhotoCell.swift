//
//  PhotoCell.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import UIKit

protocol ReusableIdentifier {
    static var reuseIdentifier: String { get }
}

extension ReusableIdentifier {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol PhotoDisplayable {
    func display(photo: Photo) async
}

class PhotoCell: UICollectionViewCell, ReusableIdentifier {
    var downloadTask: URLSessionDataTask?
    var currentURL: URL?
    var imageCache: ImageCache!
    
    var imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        
        return imageview
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        activityIndicator.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        downloadTask?.cancel()
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}

extension PhotoCell: PhotoDisplayable {
    func display(photo: Photo) async {
        
        imageView.image = nil
        downloadTask?.cancel()
        
        if let url = URL(string: photo.downloadURL) {
            currentURL = url
            
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            if let cachedImage = imageCache.image(for: url) {
                self.imageView.image = cachedImage
                stopActivityIndicator()
            } else {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    DispatchQueue.global(qos: .userInitiated).async {
                        if let image = UIImage(data: data),
                           let thumbnailImage = image.resizedImage(withPercentage: 0.1) {
                            DispatchQueue.main.async {
                                if self.currentURL == url {
                                    self.imageView.image = thumbnailImage
                                    self.stopActivityIndicator()
                                }
                            }
                            Task {
                                await  self.imageCache.setImage(thumbnailImage, for: url)
                            }
                        }
                    }
                    
                } catch  {
                   stopActivityIndicator()
                }
            }
        }
    }
    
    func stopActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}
