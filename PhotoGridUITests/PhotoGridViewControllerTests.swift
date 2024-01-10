//
//  PhotoGridViewControllerTests.swift
//  PhotoGridUITests
//
//  Created by Saggy on 10/01/24.
//

import XCTest

final class PhotoGridViewControllerTests: XCTestCase {
    
    private let app = XCUIApplication()
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func test_PhotoGridView_OnAppear_ShouldLoadUIElements() {
        
        // Act
        let collectionView = app.collectionViews.firstMatch
        
        // Assert
        XCTAssertTrue(collectionView.exists)
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
        XCTAssertTrue(collectionView.cells.count > 0)
    }
    
    func test_PhotoGridView_OnTapOfAnyImage_ShouldNavigatwToFullImageScreen() {
        
        // Arrange
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 10))
        let imageToBeTapIndex = 11

        // Act
        let tappedImage = collectionView.children(matching: .cell).element(boundBy: imageToBeTapIndex)
        
        XCTAssertTrue(tappedImage.waitForExistence(timeout: 10))

        tappedImage.tap()
        
        XCTAssertTrue(app.images["FullImageView"].waitForExistence(timeout: 10))
    }
}
