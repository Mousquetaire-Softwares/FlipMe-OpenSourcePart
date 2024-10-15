//
//  DeckModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 15/01/2024.
//

import XCTest
@testable import Concentration_Storyboard

final class DeckModelTests: XCTestCase {
    fileprivate var imagesPickerWith3Images : ImagesLibraryPickerModelProtocol!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        imagesPickerWith3Images = ImagesLibraryPickerModel(using: MockImagesLibraryModelWith3Images())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        imagesPickerWith3Images = nil
    }
    
    func test_Initialization() {
        let _ = SingleImageDeckModel(imagesPicker:imagesPickerWith3Images)
    }
    
    func test_PopRandomMatchingCardsModel() {
        var sut = SingleImageDeckModel(imagesPicker:imagesPickerWith3Images)
        
        let matchingCardsModel = sut.getUniqueMatchingCardsModel()
        
        XCTAssertNotNil(matchingCardsModel)
        XCTAssertEqual(sut.remainingMatchingCardsModels, 3-1)
    }
    
    func test_PopRandomMatchingCardsModel_WhenEmpty_ShouldBeNil() {
        var sut = SingleImageDeckModel(imagesPicker:imagesPickerWith3Images)
        var sutEmpty = SingleImageDeckModel(imagesPicker:MockImagesLibraryPickerModelEmpty())
        
        let result1 = sutEmpty.getUniqueMatchingCardsModel()
        let _ = sut.getUniqueMatchingCardsModel()
        let _ = sut.getUniqueMatchingCardsModel()
        let _ = sut.getUniqueMatchingCardsModel()
        let result2 = sut.getUniqueMatchingCardsModel()
        
        XCTAssertNil(result1)
        XCTAssertNil(result2)
        XCTAssertEqual(sut.remainingMatchingCardsModels, 0)
        XCTAssertEqual(sutEmpty.remainingMatchingCardsModels, 0)
    }
    
    func test_RemainingMatchingCardsModels() {
        let sut = SingleImageDeckModel(imagesPicker:imagesPickerWith3Images)
        
        XCTAssertEqual(sut.remainingMatchingCardsModels, 3)
    }
    
}

