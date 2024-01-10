//
//  ImageCache.swift
//  PhotoGridTests
//
//  Created by Saggy on 10/01/24.
//

import XCTest
import Combine
@testable import PhotoGrid

final class ImageCacheTests: XCTestCase {
    
    private var imageCache: ImageCache!
    
    override func setUp() {
        super.setUp()
        imageCache = ImageCache()
    }
    
    func testSetImage() async throws {
    
        // Arrange
        guard let url = URL(string: "https://picsum.photos/id/0/5000/3333") else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let originalImage = UIImage(data: data) else {
            XCTFail()
            return
        }
        
        // Act
            imageCache.setImage(originalImage, for: url)
        
        // Assert
        XCTAssertNotNil(imageCache.image(for: url))
    }
    
    func testGetImage() async throws {
    
        // Arrange
        guard let url = URL(string: "https://picsum.photos/id/0/5000/3333") else { return }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let originalImage = UIImage(data: data) else {
            XCTFail()
            return
        }
        
        // Act
            imageCache.setImage(originalImage, for: url)
            let cachedImage = imageCache.image(for: url)
        
        // Assert
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(originalImage.pngData(), cachedImage?.pngData())
    }
}
