//
//  PhotoGridViewModel.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import Foundation
import Combine

class PhotoGridViewModel {
    private let networkFetcher:  NetworkFetchable
    private var photos: [Photo] = []
    var photoPublisher = PassthroughSubject<[Photo], Error>()

    init(networkFetcher: NetworkFetchable) {
        self.networkFetcher = networkFetcher
    }
    
    func fetchPhotos() async {
        do {
            photos = try await networkFetcher.fetchData()
            photoPublisher.send(photos)
        } catch {
            photoPublisher.send(completion: .failure(error))
        }
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    func photoAtIndex(_ index: Int) -> Photo {
        return photos[index]
    }
}
