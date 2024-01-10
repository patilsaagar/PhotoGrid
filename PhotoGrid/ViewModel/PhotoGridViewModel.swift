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
    private var todaysDate: Date
    var photoPublisher = PassthroughSubject<[Photo], Error>()

    init(networkFetcher: NetworkFetchable, todaysDate: Date = Date()) {
        self.networkFetcher = networkFetcher
        self.todaysDate = todaysDate
    }
    
    func fetchPhotos() async {
        do {
            photos = try await networkFetcher.makeHttpRequest(from: APIConstants.endpoint)
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
    
    func getTodaysDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = StringConstants.dateFormat

        return dateFormatter.string(from: todaysDate)
    }
    
    func prefetchandCacheImage(url: URL) async throws -> Data {
        let fetchedImage: Data = try await networkFetcher.fetchData(from: url.absoluteString)
        return fetchedImage
    }
}
