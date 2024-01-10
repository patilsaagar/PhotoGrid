//
//  PhotoGridViewControllerTests.swift
//  PhotoGridUITests
//
//  Created by Saggy on 10/01/24.
//

import XCTest

final class PhotoGridViewControllerTests: XCTestCase {
    
    let app = XCUIApplication()
    
    // MARK: Setup
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func test_PhotoGridView_OnAppear_ShouldLoadUIElements() {
        
        // ACT
        let collectionView = app.collectionViews.firstMatch
        
        // ASSERT
        XCTAssertTrue(collectionView.exists)
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))
        XCTAssertTrue(collectionView.cells.count > 0)
    }
    
    func test_PhotoGridView_OnTapOfAnyImage_ShouldNavigatwToFullImageScreen() {
        
        // ACT
        let collectionView = app.collectionViews.firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: 10))

        // ACT
        let imageToBeTapIndex = 11
        let tappedImage = collectionView.children(matching: .cell).element(boundBy: imageToBeTapIndex)
        
        XCTAssertTrue(tappedImage.waitForExistence(timeout: 10))

        tappedImage.tap()
        
        XCTAssertTrue(app.images["FullImageView"].waitForExistence(timeout: 10))
    }
}
