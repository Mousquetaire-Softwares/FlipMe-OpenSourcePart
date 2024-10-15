//
//  LevelsLibraryDatabaseTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 24/04/2024.
//

import XCTest
@testable import FlipMe_OpenSource

class TestableLevelsLibraryDatabase : LevelsLibraryDatabase {
    private let mockUserDefaults = MockUserDefaults()
    override func userDefaults() -> UserDefaults {
        return mockUserDefaults
    }
}

final class LevelsLibraryDatabaseTests: XCTestCase {
    var sut : TestableLevelsLibraryDatabase!
    let libraryVersion = GameDatabase.LibraryVersion.ReleaseV1
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = TestableLevelsLibraryDatabase(version: libraryVersion)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func test_StagesParameters_StagesIds_ShouldBeUnique() {
        let stagesParameters = sut.stagesParameters
        let uniqueIds = Set<InvariantId>(stagesParameters.filter{ !$0.stageId.isEmpty }.map{ $0.stageId })
        
        XCTAssertEqual(uniqueIds.count, stagesParameters.count)
    }
    
    func test_StagesParameters_LevelsIds_ShouldBeUnique() {
        let stagesParameters = sut.stagesParameters
        let uniqueIds = Set<InvariantId>(stagesParameters.filter{ !$0.stageId.isEmpty }.flatMap{ $0.levels.map{ $0.levelId } })
        
        XCTAssertEqual(uniqueIds.count, stagesParameters.reduce( 0, { $0 + $1.levels.count }))
    }

    func test_StagesParameters_LevelsIds_LockedLevelsCountShouldEqualsLockedImagesCounts() {
        let imagesLibraryDatabase = TestableImagesLibraryDatabase(version: libraryVersion)
        
        let levelsLockedByDefaultCount = sut.stagesParameters.flatMap{ $0.levels.map{ $0.unlockedByDefault } }.filter{ $0 == false}.count
        let imagesLockedByDefaultCount = imagesLibraryDatabase.allImages.subtracting(imagesLibraryDatabase.starterSet).count
        
        XCTAssertEqual(levelsLockedByDefaultCount, imagesLockedByDefaultCount)
    }

    func test_save_ShouldSaveContentOfLevelsUnlockedIds() {
        var mockLevelsUnlockedIds : Set<InvariantId> = [TestsValues.String2, TestsValues.String3]
        sut.levelsUnlockedIds = mockLevelsUnlockedIds
        
        sut.save(to: .UserDefaults)
        
        let userDefaultsContents = sut.userDefaults().array(forKey: GameDatabase.DataKeys.LevelsUnlockedIds) as? [String]
        XCTAssertNotNil(userDefaultsContents)
        XCTAssertEqual(Set(userDefaultsContents!)
                       , mockLevelsUnlockedIds)
    }
    func test_save_ShouldSaveContentOfLevelsPoints() {
        var mockLevelsPoints : [InvariantId:Float] = [TestsValues.String1:Float(TestsValues.Int1)]
        sut.levelsPoints = mockLevelsPoints
        
        sut.save(to: .UserDefaults)
        
        let userDefaultsContents = sut.userDefaults().dictionary(forKey: GameDatabase.DataKeys.LevelsPointsStates) as? [InvariantId:Float]
        XCTAssertNotNil(userDefaultsContents)
        XCTAssertEqual(userDefaultsContents!
                       , mockLevelsPoints)
    }
    func test_save_ShouldSaveContentOfLevelsBestScores() {
        var mockLevelsBestScores : [InvariantId:Float] = [TestsValues.String1:Float(TestsValues.Int1)]
        sut.levelsBestScores = mockLevelsBestScores
        
        sut.save(to: .UserDefaults)
        
        let userDefaultsContents = sut.userDefaults().dictionary(forKey: GameDatabase.DataKeys.LevelsBestScores) as? [InvariantId:Float]
        XCTAssertNotNil(userDefaultsContents)
        XCTAssertEqual(userDefaultsContents!
                       , mockLevelsBestScores)
    }

    func test_load_ShouldLoadContentOfLevelsUnlockedIds() {
        let sutCopy = TestableLevelsLibraryDatabase(version: libraryVersion)
        let sutEmpty = TestableLevelsLibraryDatabase(version: libraryVersion)
        var mockLevelsUnlockedIds : Set<InvariantId> = [TestsValues.String2, TestsValues.String3]
        
        sut.levelsUnlockedIds = mockLevelsUnlockedIds
        sut.save(to: .UserDefaults)
        sutCopy.load(from: .UserDefaults)
        
        XCTAssertEqual(sutCopy.levelsUnlockedIds
                       , mockLevelsUnlockedIds)
        XCTAssertTrue(sutEmpty.levelsUnlockedIds.isEmpty)
    }

    func test_load_ShouldLoadContentOfLegacyLevelsUnlockedStates() {
        var mockLegacyLevelsUnlockedStates = [TestsValues.String2:true,TestsValues.String3:false]
        let sutWithUnlockedIds = TestableLevelsLibraryDatabase(version: libraryVersion)
        var mockLevelsUnlockedIds : Set<InvariantId> = [TestsValues.String1, TestsValues.String3]
        
        sut.userDefaults().set(mockLegacyLevelsUnlockedStates, forKey: GameDatabase.DataKeys.LevelsUnlockedStates)
        sut.load(from: .UserDefaults)
        
        sut.userDefaults().set(mockLevelsUnlockedIds.sorted(), forKey: GameDatabase.DataKeys.LevelsUnlockedIds)
        sutWithUnlockedIds.load(from: .UserDefaults)
        sutWithUnlockedIds.save(to: .UserDefaults)
        sutWithUnlockedIds.load(from: .UserDefaults)

        XCTAssertEqual(sut.levelsUnlockedIds
                       , Set([TestsValues.String2]))
        XCTAssertEqual(sutWithUnlockedIds.levelsUnlockedIds
                       , mockLevelsUnlockedIds.union([TestsValues.String2]))
    }

    func test_load_ShouldLoadContentOfLevelsPoints() {
        let sutCopy = TestableLevelsLibraryDatabase(version: libraryVersion)
        let sutEmpty = TestableLevelsLibraryDatabase(version: libraryVersion)
        var mockLevelsPoints : [InvariantId:Float] = [TestsValues.String1:Float(TestsValues.Int1)]
        
        sut.levelsPoints = mockLevelsPoints
        sut.save(to: .UserDefaults)
        sutCopy.load(from: .UserDefaults)
        
        XCTAssertEqual(sutCopy.levelsPoints
                       , mockLevelsPoints)
        XCTAssertTrue(sutEmpty.levelsPoints.isEmpty)
    }

    func test_load_ShouldLoadContentOfLevelsBestScores() {
        let sutCopy = TestableLevelsLibraryDatabase(version: libraryVersion)
        let sutEmpty = TestableLevelsLibraryDatabase(version: libraryVersion)
        var mockLevelsBestScores : [InvariantId:Float] = [TestsValues.String1:Float(TestsValues.Int2)]
        
        sut.levelsBestScores = mockLevelsBestScores
        sut.save(to: .UserDefaults)
        sutCopy.load(from: .UserDefaults)
        
        XCTAssertEqual(sutCopy.levelsBestScores
                       , mockLevelsBestScores)
        XCTAssertTrue(sutEmpty.levelsBestScores.isEmpty)
    }

}
