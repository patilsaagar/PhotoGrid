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

class MockNetworkFetcher: NetworkFetchable {
    
    private var fetchDataCallCount = 0
    private var mockData: Data

    init(mockData: Data) {
        self.mockData = mockData
    }
    
    func fetchData<T: Decodable>(from url: String) async throws -> T {
        fetchDataCallCount += 1

        let decodedData = try JSONDecoder().decode(T.self, from: mockData)
        
        return decodedData
    }
    
    func getFetchDataCallCount() -> Int {
        return fetchDataCallCount
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
        
        
        _ = photoGridViewModel.photoPublisher
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
        XCTAssertEqual(2, receivedPhoto?.count)
        XCTAssertEqual(mockNetworkFetcher.getFetchDataCallCount(), 1)
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
}
