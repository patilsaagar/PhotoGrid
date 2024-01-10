//
//  PhotoGridViewModelTests.swift
//  PhotoGridTests
//
//  Created by Saggy on 10/01/24.
//

import XCTest
import Combine
@testable import PhotoGrid

struct MockData: Codable {
    let id, author: String
    let width, height: Int
    let downloadURL: String

    enum CodingKeys: String, CodingKey {
        case id, author, width, height
        case downloadURL = "download_url"
    }
}

final class PhotoGridViewModelTests: XCTestCase {

    private var fetchDataCallCount = 0
    private var mockNetworkFetcher: MockNetworkFetcher!

    override func setUp() {
        super.setUp()
        
        let mockDataFirst = MockData(id: "1", author: "Auther1", width: 5000, height: 333, downloadURL: "https://picsum.photos/id/0/5000/3333")
        let mockDataSecond = MockData(id: "2", author: "Auther2", width: 5000, height: 333, downloadURL: "https://picsum.photos/id/1/5000/3333")

        let mockdataArray = [mockDataFirst, mockDataSecond]
        let data = try! JSONEncoder().encode(mockdataArray)
        mockNetworkFetcher = MockNetworkFetcher(mockData: data)
    }
    
    func testFetchPhotoSuccess() async throws {
        
        // Arrange
        let photoGridViewModel = PhotoGridViewModel(networkFetcher: mockNetworkFetcher)
        let expectation = expectation(description: "Photo fetched successfully")
        var receivedPhoto: [Photo]?
        var receivedError: Error?
        
        
        let cancellable = photoGridViewModel.photoPublisher
            .sink { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                    
                case .failure(let error):
                    receivedError = error
                    expectation.fulfill()
                }
            } receiveValue: { photos in
                receivedPhoto = photos
            }
        
        // Act
        await photoGridViewModel.fetchPhotos()
        
        // Assert
        await XCTestCase().fulfillment(of: [expectation], timeout: 5)
        XCTAssertNil(receivedError)
        XCTAssertNotNil(receivedPhoto)
        XCTAssertEqual(receivedPhoto?.count, photoGridViewModel.numberOfPhotos())
        XCTAssertEqual(mockNetworkFetcher.getFetchDataCallCount(), 1)
        
        cancellable.cancel()
    }
    
    func testNumberOfPhotos() async throws {
        // Arrange
        let photoGridViewModel = PhotoGridViewModel(networkFetcher: mockNetworkFetcher)
        
        // Act
        await photoGridViewModel.fetchPhotos()
        
        // Assert
        XCTAssertEqual(photoGridViewModel.numberOfPhotos(), 2)
    }
    
    func testPhotoAtIndex()  async throws {
        // Arrange
        let photoGridViewModel = PhotoGridViewModel(networkFetcher: mockNetworkFetcher)
        
        // Act
        await photoGridViewModel.fetchPhotos()
        let photo = photoGridViewModel.photoAtIndex(0)
        
        // Assert
        XCTAssertEqual(photo.id, "1")
        XCTAssertEqual(photo.author, "Auther1")
        XCTAssertEqual(photo.downloadURL, "https://picsum.photos/id/0/5000/3333")
    }
    
    func testGetTodaysDate() {
        
        // Arrange
        let photoGridViewModel = PhotoGridViewModel(networkFetcher: mockNetworkFetcher, todaysDate: Date(timeIntervalSince1970: 0))
        
        // Act
        let todaysDate = photoGridViewModel.getTodaysDate()
        
        // Assert
        XCTAssertEqual(todaysDate, "Jan 1, 1970")
    }
}
