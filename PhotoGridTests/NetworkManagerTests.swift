//
//  NetworkManagerTests.swift
//  PhotoGridTests
//
//  Created by Saggy on 10/01/24.
//

import XCTest
import Combine
@testable import PhotoGrid

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
    
    func testFetchDataSuccess() async throws {
        // Arrange
        let mockDataFirst = MockData(id: "1", author: "Auther1", width: 5000, height: 333, downloadURL: "https://picsum.photos/id/0/5000/3333")
        let mockDataSecond = MockData(id: "2", author: "Auther2", width: 5000, height: 333, downloadURL: "https://picsum.photos/id/1/5000/3333")

        let mockdataArray = [mockDataFirst, mockDataSecond]
        let data = try! JSONEncoder().encode(mockdataArray)
        mockURLSession.mockData = data
        
        // Act
        let receivedData:[MockData] =  try await networkManager.makeHttpRequest(from: APIConstants.endpoint)
        
        // Assert
        XCTAssertEqual(receivedData.count, 2)
    }
}
