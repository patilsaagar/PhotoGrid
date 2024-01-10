//
//  PhotoCell.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import UIKit

protocol ReuseIdentifier {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifier {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol PhotoDisplay {
    func display(photo: Photo) async
}

class PhotoCell: UICollectionViewCell, ReuseIdentifier {
    var downloadTask: URLSessionDataTask?
    var currentPhotoID: String?
    var imageCache: ImageCache!
    
    var photoGridImageView: UIImageView = {
        let gridImageView = UIImageView()
        gridImageView.translatesAutoresizingMaskIntoConstraints = false
        gridImageView.contentMode = .scaleAspectFill
        gridImageView.clipsToBounds = true
        
        return gridImageView
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(photoGridImageView)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoGridImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoGridImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoGridImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            photoGridImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
        
        activityIndicator.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoGridImageView.image = nil
        downloadTask?.cancel()
        stopActivityIndicator()
    }
}

extension PhotoCell: PhotoDisplay {
    func display(photo: Photo) async {
        
        photoGridImageView.image = nil
        downloadTask?.cancel()
        
        if let url = URL(string: photo.downloadURL) {
            currentPhotoID = photo.id
            
            startActivityIndicator()
            if let cachedImage = imageCache.image(for: url) {
                self.photoGridImageView.image = cachedImage
                stopActivityIndicator()
            } else {
                await displayImage(photo: photo, url: url)
            }
        }
    }
}

extension PhotoCell {
        
    private func startActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func stopActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func displayImage(photo: Photo, url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            DispatchQueue.global(qos: .userInitiated).async {
                if let image = UIImage(data: data),
                   let thumbnailImage = image.resizedImage(withPercentage: 0.1) {
                    DispatchQueue.main.async {
                        if self.currentPhotoID == photo.id {
                            self.photoGridImageView.image = thumbnailImage
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
