//
//  ImagesLibraryDatabaseTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 19/04/2024.
//

import XCTest
@testable import FlipMe_OpenSource


class TestableImagesLibraryDatabase : ImagesLibraryDatabase {
    private let mockUserDefaults = MockUserDefaults()
    override func userDefaults() -> UserDefaults {
        return mockUserDefaults
    }
}

final class ImagesLibraryDatabaseTests: XCTestCase {
    var sut : TestableImagesLibraryDatabase!
    let libraryVersion = GameDatabase.LibraryVersion.ReleaseV1
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = TestableImagesLibraryDatabase(version: libraryVersion)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func test_unlockedSet_ShouldBeEmpty() {
        XCTAssertTrue(sut.unlockedSet.isEmpty)
    }
    
    func test_AllSets_ShouldHaveUniqueValues() {
        let allImages = Set(sut.allSets.flatMap{ $0 })
        
        XCTAssertEqual(sut.allSets.reduce(0, { $0 + $1.count }), allImages.count, "Duplicates across sets")
    }

    func test_AllSets_ShouldAllExistsInAsset() {
        let sut = ImagesLibraryDatabase(version: libraryVersion)
        
        
        let allImageNames : [ImageName] = sut.allSets.flatMap{ $0 }
        for imageName in allImageNames {
            let image = UIImage(named: imageName)
            XCTAssertNotNil(image, "Missing image named : \(imageName)")
        }
    }
    
    func test_StarterSet_ShouldHave23Images() {
        let numberOfImageInStarterSet = 23
        
        XCTAssertEqual(sut.starterSet.count, numberOfImageInStarterSet)
    }
    
    
    func test_saveUnlockedSet_ShouldSaveContentOfUnlockedSet() {
        let mockUnlockedValues = Set([TestsValues.String1, TestsValues.String2])
        sut.unlockedSet = ImageSet(mockUnlockedValues)
        
        sut.saveUnlockedSet(to: .UserDefaults)
        
        let userDefaultsContents = sut.userDefaults().array(forKey: GameDatabase.DataKeys.ImagesNamesUnlocked) as? [String]
        XCTAssertNotNil(userDefaultsContents)
        XCTAssertEqual(Set(userDefaultsContents!)
                       , mockUnlockedValues)
    }

    func test_loadUnlockedSet_ShouldLoadContentOfUnlockedSet() {
        let sutCopy = TestableImagesLibraryDatabase(version: libraryVersion)
        let sutEmpty = TestableImagesLibraryDatabase(version: libraryVersion)
        let mockUnlockedValues = Set([TestsValues.String1, TestsValues.String2])
        
        sut.unlockedSet = mockUnlockedValues
        sut.saveUnlockedSet(to: .UserDefaults)
        sutCopy.loadUnlockedSet(from: .UserDefaults)
        
        XCTAssertEqual(sutCopy.unlockedSet
                       , mockUnlockedValues)
        XCTAssertTrue(sutEmpty.unlockedSet.isEmpty)
    }

}
