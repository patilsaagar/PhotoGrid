//
//  NetworkManagerTests.swift
//  PhotoGridTests
//
//  Created by Saggy on 10/01/24.
//

import XCTest
import Combine
@testable import PhotoGrid

class MockNetworkFetcher: NetworkFetchable {
    private var fetchDataCallCount = 0
    private var mockData: Data

    init(mockData: Data) {
        self.mockData = mockData
    }
    
    func makeHttpRequest<T: Decodable>(from url: String) async throws -> T {
        fetchDataCallCount += 1

        let decodedData = try JSONDecoder().decode(T.self, from: mockData)
        
        return decodedData
    }
    
    func getFetchDataCallCount() -> Int {
        return fetchDataCallCount
    }
    
    func fetchData(from endpointURL: String) async throws -> Data {
        return mockData
    }
}

class MockURLSession: URLSessionProtocol {
    
    var mockData: Data?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        guard let mockData = mockData else {
            throw URLError(.badServerResponse)
        }
        
        return (mockData, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }
}

final class NetworkManagerTests: XCTestCase {
    private var networkManager: NetworkManager!
    private var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkManager = NetworkManager(urlSession: mockURLSession)
    }
    
    func testMakeHttpRequestSuccess() async throws {
        // Arrange
        let mockDataFirst = MockData(id: "1", author: "Auther1", width: 5000, height: 333, downloadURL: "https://picsum.photos/id/0/5000/3333")
        let mockDataSecond = MockData(id: "2", author: "Auther2", width: 5000, height: 333, downloadURL: "https://picsum.photos/id/1/5000/3333")

        let mockdataArray = [mockDataFirst, mockDataSecond]
        let data = try! JSONEncoder().encode(mockdataArray)
        mockURLSession.mockData = data
        let expectation = expectation(description: "Data fetched successfully")
        
        // Act
        Task {
            do {
                let receivedData:[MockData] =  try await networkManager.makeHttpRequest(from: APIConstants.endpoint)
                
                // Assert
                XCTAssertEqual(receivedData.count, 2)
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        await XCTestCase().fulfillment(of: [expectation], timeout: 5)
    }
    
    func testFetchDataSuccess() async throws {
        // Arrange
        let mockDataFirst = MockData(id: "1", author: "Auther1", width: 5000, height: 333, downloadURL: "https://picsum.photos/id/0/5000/3333")

        let mockdataArray = mockDataFirst
        let mockData = try! JSONEncoder().encode(mockdataArray)
        mockURLSession.mockData = mockData
        let mockNetworkFetcher = MockNetworkFetcher(mockData: mockData)
        
        // Act
        let resultData = try await mockNetworkFetcher.fetchData(from: APIConstants.endpoint)
        
        // Assert
        XCTAssertNotNil(resultData)
        XCTAssertEqual(resultData, mockData)
    }
}
