//
//  BackgroundsLibraryModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 03/04/2024.
//

import XCTest
@testable import Concentration_Storyboard

final class BackgroundsLibraryModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_Shared_AvailableSetsShouldAllExistsInAsset() {
        let menuImages = BackgroundsLibraryModel.Shared.menuAvailableSet().map{ $0.image }
        let gametableImages = BackgroundsLibraryModel.Shared.gametableAvailableSet()
        let allImages = gametableImages.union(menuImages)
        
        allImages.forEach {
            let image = UIImage(named: $0)
            XCTAssertNotNil(image, "Missing image named : \($0)")
        }
    }


}
