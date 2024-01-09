//
//  PhotoGridViewModel.swift
//  PhotoGrid
//
//  Created by Saggy on 09/01/24.
//

import Foundation

class PhotoGridViewModel {
    private let networkFetcher:  NetworkFetchable
    private var photos: [Photo] = []

    init(networkFetcher: NetworkFetchable) {
        self.networkFetcher = networkFetcher
    }
    
    func fetchPhotos() async {
        do {
            photos = try await networkFetcher.fetchData()
        } catch {
            
        }
    }
    
    func numberOfPhotos() -> Int {
        return photos.count
    }
    
    func photoAtIndex(_ index: Int) -> Photo {
        return photos[index]
    }
}
