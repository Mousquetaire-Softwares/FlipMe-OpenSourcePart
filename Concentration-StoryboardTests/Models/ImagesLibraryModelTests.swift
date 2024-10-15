//
//  ImagesLibraryModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 15/01/2024.
//

import XCTest
@testable import FlipMe_OpenSource

final class ImagesLibraryModelTests: XCTestCase {
    var sut : ImagesLibraryModel!
    var mockDatabase : MockImagesLibraryDatabase!
    let libraryVersion = GameDatabase.LibraryVersion.ReleaseV1
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockDatabase = MockImagesLibraryDatabase()
        sut = ImagesLibraryModel(database: mockDatabase, userDataLocation: .UserDefaults)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mockDatabase = nil
    }
    
    func test_WithRealLibrary_availableSet_EachCategoryShouldHaveEnoughImages() {
        let testableRealDatabase = TestableImagesLibraryDatabase(version: libraryVersion)
        let sutReleasedVersion = ImagesLibraryModel(database: testableRealDatabase, userDataLocation: .UserDefaults)
        
        let minimumNumberOfImagePerCategory = 13
        
        ImageCategory.allCases.forEach {
            debugPrint($0, sutReleasedVersion.filter(sutReleasedVersion.availableSet, for: $0).count)
            XCTAssertGreaterThanOrEqual(sutReleasedVersion.filter(sutReleasedVersion.availableSet, for: $0).count, minimumNumberOfImagePerCategory)
        }
    }
    
    func test_create_ShouldCallDatabaseLoadUnlockedSet() {
        XCTAssertEqual(mockDatabase.loadUnlockedSetCalls, 1)
    }
    
    func test_loadValues_ShouldCallDatabaseLoadUnlockedSet() {
        sut.loadDatabaseValues()
        
        XCTAssertEqual(mockDatabase.loadUnlockedSetCalls, 2)
        XCTAssertEqual(mockDatabase.saveUnlockedSetCalls, 0)
    }
    
    func test_saveValues_ShouldCallDatabaseSaveUnlockedSet() {
        sut.saveDatabaseValues()
        
        XCTAssertEqual(mockDatabase.loadUnlockedSetCalls, 1)
        XCTAssertEqual(mockDatabase.saveUnlockedSetCalls, 1)
    }
    
    // AvailableSet / LockedSet
    func test_availableSet_LockedSet_WithUnlockedSetNotEmpty() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        mockDatabase.setForCardsWithDoubleImages = []
        mockDatabase.setForCardsWithDoubleImagesDoubleOrder = []
        mockDatabase.setForCardsWithMultiColorBackground = []
        mockDatabase.starterSet = [TestsValues.String1]
        mockDatabase.unlockedSet = [TestsValues.String3]
        
        XCTAssertEqual(sut.availableSet, ImageSet([TestsValues.String1, TestsValues.String3]))
        XCTAssertEqual(sut.lockedSet, ImageSet([TestsValues.String2]))
    }
    
    func test_availableSet_LockedSet_WithUnlockedSetEmpty() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        mockDatabase.starterSet = [TestsValues.String2]
        mockDatabase.unlockedSet = []
        
        XCTAssertEqual(sut.availableSet, ImageSet([TestsValues.String2]))
        XCTAssertEqual(sut.lockedSet, ImageSet([TestsValues.String1, TestsValues.String3]))
    }
    
    // LockedImageAvailable
    func test_lockedImageAvailable_WithAllImagesUnlocked() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        mockDatabase.setForCardsWithDoubleImages = []
        mockDatabase.starterSet = [TestsValues.String,TestsValues.String1]
        mockDatabase.unlockedSet = [TestsValues.String2, TestsValues.String3]
        
        XCTAssertFalse(sut.lockedImageAvailable())
    }
    func test_lockedImageAvailable_WithNotAllImagesUnlocked() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        mockDatabase.setForCardsWithDoubleImages = []
        mockDatabase.starterSet = [TestsValues.String1]
        mockDatabase.unlockedSet = [TestsValues.String3]
        
        XCTAssertTrue(sut.lockedImageAvailable())
    }
//    func test_lockedImageAvailable_WithAllImagesUnlocked() {
//        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
//        mockDatabase.setForCardsWithDoubleImages = []
//        mockDatabase.starterSet = [TestsValues.String1]
//        mockDatabase.unlockedSet = [TestsValues.String2, TestsValues.String3]
//        
//        XCTAssertFalse(sut.lockedImageAvailable(for: .AnyImage))
//        XCTAssertFalse(sut.lockedImageAvailable(for: .ImageForCardsWithDoubleImages))
//    }
//    
//    func test_lockedImageAvailable_WithLockedImagesOnlyForCardsWithDoubleImages() {
//        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
//        mockDatabase.setForCardsWithDoubleImages = [TestsValues.String2]
//        mockDatabase.starterSet = [TestsValues.String1]
//        
//        XCTAssertTrue(sut.lockedImageAvailable(for: .AnyImage))
//        XCTAssertTrue(sut.lockedImageAvailable(for: .ImageForCardsWithDoubleImages))
//        XCTAssertFalse(sut.lockedImageAvailable(for: .ImageForCardsWithDoubleImagesDoubleOrder))
//        XCTAssertFalse(sut.lockedImageAvailable(for: .ImageForCardsWithDoubleImages
//                                                , and: .ImageForMulticolorBackground))
//    }
//    
//    func test_lockedImageAvailable_WithLockedImagesForCardsCombination() {
//        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
//        mockDatabase.setForCardsWithDoubleImages = [TestsValues.String2, TestsValues.String3]
//        mockDatabase.setForCardsWithDoubleImagesDoubleOrder = [TestsValues.String1,TestsValues.String2]
//        mockDatabase.setForCardsWithMultiColorBackground = [TestsValues.String1,TestsValues.String3]
//        mockDatabase.starterSet = [TestsValues.String1]
//        
//        XCTAssertTrue(sut.lockedImageAvailable(for: .AnyImage))
//        XCTAssertTrue(sut.lockedImageAvailable(for: .ImageForCardsWithDoubleImages
//                                               , and: .ImageForMulticolorBackground))
//        XCTAssertTrue(sut.lockedImageAvailable(for: .ImageForCardsWithDoubleImages
//                                               , and: .ImageForCardsWithDoubleImagesDoubleOrder))
//        XCTAssertFalse(sut.lockedImageAvailable(for: .ImageForCardsWithDoubleImagesDoubleOrder
//                                               , and: .ImageForMulticolorBackground))
//    }
    
    // getRandomLockedImage
    func test_getRandomLockedImage_WithAllImagesUnlocked() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        mockDatabase.setForCardsWithDoubleImages = []
        mockDatabase.starterSet = [TestsValues.String,TestsValues.String1]
        mockDatabase.unlockedSet = [TestsValues.String2, TestsValues.String3]
        
        XCTAssertNil(sut.getRandomLockedImage())
    }
    func test_getRandomLockedImage_WithNotAllImagesUnlocked() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        mockDatabase.setForCardsWithDoubleImages = []
        mockDatabase.starterSet = [TestsValues.String1]
        mockDatabase.unlockedSet = [TestsValues.String3]
        
        XCTAssertNotNil(sut.getRandomLockedImage())
    }
    
    func test_getRandomLockedImage_WithImageCategoryPreference() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        var bigSet = generateImageSet(size: 99)
        mockDatabase.allSets.append(bigSet)
        
        let uniqueImageOfCategory1 = bigSet.randomElement()!
        bigSet.remove(uniqueImageOfCategory1)
        let uniqueImageOfCategory2 = bigSet.randomElement()!
        bigSet.remove(uniqueImageOfCategory2)
        let uniqueImageOfCategory3 = bigSet.randomElement()!
        bigSet.remove(uniqueImageOfCategory3)
        let imageOfCategory1And2 = bigSet.randomElement()!
        bigSet.remove(imageOfCategory1And2)
        
        bigSet.insert(uniqueImageOfCategory1)
        bigSet.insert(uniqueImageOfCategory2)
        bigSet.insert(uniqueImageOfCategory3)
        bigSet.insert(imageOfCategory1And2)
        
        let category1 = ImageCategory.ImageForCardsWithDoubleImages
        mockDatabase.setForCardsWithDoubleImages = [imageOfCategory1And2, uniqueImageOfCategory1]
        let category2 = ImageCategory.ImageForMulticolorBackground
        mockDatabase.setForCardsWithMultiColorBackground = [imageOfCategory1And2, uniqueImageOfCategory2]
        let category3 = ImageCategory.ImageForCardsWithDoubleImagesDoubleOrder
        mockDatabase.setForCardsWithDoubleImagesDoubleOrder = [uniqueImageOfCategory3]
        
        mockDatabase.starterSet = [TestsValues.String1]
        mockDatabase.unlockedSet = [TestsValues.String3]
        
        XCTAssertEqual(sut.getRandomLockedImage(), TestsValues.String2)
        XCTAssertTrue(mockDatabase.setForCardsWithDoubleImages.contains(sut.getRandomLockedImage(preferenceFor: [category1])!))
        XCTAssertEqual(sut.getRandomLockedImage(preferenceFor: [category1, category2]), imageOfCategory1And2)
        XCTAssertEqual(sut.getRandomLockedImage(preferenceFor: [category3]), uniqueImageOfCategory3)
        XCTAssertEqual(sut.getRandomLockedImage(preferenceFor: [category3, category1, category2]), uniqueImageOfCategory3)
        XCTAssertNotEqual(sut.getRandomLockedImage(preferenceFor: [category1, category2, category3]), uniqueImageOfCategory3)
    }
    
    private func generateImageSet(size:Int) -> ImageSet {
        var result = ImageSet()
        let skeleton = TestsValues.String + "ImageName"
        for i in 0..<size {
            result.insert(skeleton + "\(i)")
        }
        return result
    }
    
    // UnlockNewImage
    func test_unlockNewImage_WithUnlockedSetEmpty_ShouldUpdateDatabaseAndAvailableSet_ShouldNotSaveDatabase() {
        mockDatabase.allSets = [[TestsValues.String1],[TestsValues.String2],[TestsValues.String3]]
        mockDatabase.starterSet = [TestsValues.String2]
        mockDatabase.unlockedSet = []
        
        let unlockedImage = sut.unlockNewImage(for: .AnyImage)
        
        XCTAssertNotNil(unlockedImage)
        XCTAssertEqual(mockDatabase.saveUnlockedSetCalls, 0)
        XCTAssertEqual(mockDatabase.unlockedSet, ImageSet([unlockedImage!]))
        XCTAssertEqual(sut.availableSet, ImageSet([TestsValues.String2, unlockedImage!]))
    }

    
}
