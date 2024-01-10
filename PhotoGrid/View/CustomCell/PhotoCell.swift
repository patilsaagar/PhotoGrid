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
    func configureCell(photo: Photo) async
}

class PhotoCell: UICollectionViewCell, ReuseIdentifier {
    var currentPhotoID: String?
    var imageCache: ImageCache!
    var networkFetcher = NetworkManager(urlSession: URLSession.shared)
    
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
        fatalError(StringConstants.fatalError)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoGridImageView.image = nil
        stopActivityIndicator()
        currentPhotoID = nil
    }
}

extension PhotoCell: PhotoDisplay {
    func configureCell(photo: Photo) async {
        
        photoGridImageView.image = nil
        
        guard currentPhotoID != photo.id else { return }
        currentPhotoID = photo.id
        startActivityIndicator()
        
        do {
            
            if let downloadURL = URL(string: photo.downloadURL),
               let cachedImage = imageCache.image(for: downloadURL) {
                await MainActor.run {
                    guard self.currentPhotoID == photo.id else { return }
                    self.photoGridImageView.image = cachedImage
                }
            } else {
                let fetchedImageData = try await networkFetcher.fetchData(from: photo.downloadURL)
                
                if let image = UIImage(data: fetchedImageData),
                   let thumbnailImage = image.resizedImage(withPercentage: NumberConstants.imageResizePercentage) {

                    await MainActor.run {
                        guard self.currentPhotoID == photo.id else { return }
                        self.photoGridImageView.image = thumbnailImage
                    }
                    
                    Task {
                        if let downloadURL = URL(string: photo.downloadURL) {
                            self.imageCache.setImage(thumbnailImage, for: downloadURL)
                        }
                    }
                }
            }
            self.stopActivityIndicator()
        } catch  {
            stopActivityIndicator()
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
}
