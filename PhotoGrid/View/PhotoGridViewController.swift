//
//  PhotoGridViewController.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import UIKit
import Combine

class PhotoGridViewController: UIViewController {
    
    // MARK: - Constants
    enum Constants {
        static let minimumInteritemSpacing: CGFloat         = 5
        static let imageResizePercentage: CGFloat           = 0.07
        static let photoGridColumnCount: CGFloat             = 3
        static let minimumLineSpacing: CGFloat                 = 5
        static let photoWidth: CGFloat                                 = 20
    }
    
    // MARK: - Private Variables
    private var photoViewModel: PhotoGridViewModel
    private let imageCache: ImageCache
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = Constants.minimumLineSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Init methods
    init(photoViewModel: PhotoGridViewModel, imageCache: ImageCache) {
        self.photoViewModel = photoViewModel
        self.imageCache = imageCache
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(ViewControllerInitializationErrorConstants.error)
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        setCollectionViewConstraint()
        
        setupPhotoSubsciber()
        
        Task {
            await fetchAndReloadData()
        }
    }
}

// MARK: - Private methods
extension PhotoGridViewController {
    
    private func setupPhotoSubsciber() {
        
        photoViewModel.photoPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break;
                case .failure(let error):
                    self?.handleError(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    private func handleError(error: Error) {
        
        let alertController = UIAlertController(title: AlertConstants.title, 
                                                message: AlertConstants.messageBody,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: AlertConstants.okButton, style: .default, handler: nil))
        present(alertController, animated: true)
        
    }
    
    private func setCollectionViewConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func fetchAndReloadData()  async {
        await photoViewModel.fetchPhotos()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource methods
extension PhotoGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoViewModel.numberOfPhotos()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        
        photoCell.imageCache = imageCache
        let photo = photoViewModel.photoAtIndex(indexPath.row)
        
        Task {
            await photoCell.display(photo: photo)
        }
        return photoCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout methods
extension PhotoGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - Constants.photoWidth)  / Constants.photoGridColumnCount
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - UICollectionViewDelegate methods
extension PhotoGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photoViewModel.photoAtIndex(indexPath.row)
        let fullPhotoViewController = FullPhotoViewController(photo: photo, imageCache: imageCache)
        
        self.navigationController?.pushViewController(fullPhotoViewController, animated: false)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching methods
extension PhotoGridViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in indexPaths {
            guard indexPath.row < photoViewModel.numberOfPhotos() else { return }
            
            let photo = photoViewModel.photoAtIndex(indexPath.row)
            let downloadURL = URL(string: photo.downloadURL)
            
            if let downloadURL = downloadURL {
                if let cachedImage = imageCache.image(for: downloadURL) {
                    (collectionView.cellForItem(at: indexPath) as? PhotoCell)?.imageView.image = cachedImage
                } else {
                    guard visibleIndexPaths.contains(indexPath) else { continue }
                    
                    Task {
                        do {
                            let (data, _) = try await URLSession.shared.data(from: downloadURL)
                            let image = UIImage(data: data)!
                            let thumbnailImage = image.resizedImage(withPercentage: Constants.imageResizePercentage)
                            
                            DispatchQueue.main.async {
                                if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell,
                                   visibleIndexPaths.contains(indexPath) {
                                    cell.imageView.image = thumbnailImage
                                    self.imageCache.setImage(thumbnailImage!, for: downloadURL)
                                }
                            }
                        } catch {
                            let badServerResponseError = URLError(.badServerResponse)
                            self.handleError(error: badServerResponseError)
                        }
                    }
                }
            }
        }
    }
}


