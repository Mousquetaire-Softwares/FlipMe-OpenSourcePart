//
//  LevelsLibraryModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 09/02/2024.
//

import XCTest
@testable import Concentration_Storyboard

final class LevelsLibraryModelTests: XCTestCase {
    var sut : LevelsLibraryModel!
    var mockDatabase : MockLevelsLibraryDatabase!
    var mockImagesLibrary : MockImagesLibraryModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockDatabase = MockLevelsLibraryDatabase()
        mockImagesLibrary = MockImagesLibraryModelWith3Images()
        sut = LevelsLibraryModel(with: mockDatabase
                                 , imagesLibrary: mockImagesLibrary
                                 , userDataLocation: .UserDefaults)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mockDatabase = nil
        mockImagesLibrary = nil
        sut = nil
    }
    
    
    func test_create_ShouldCallDatabaseLoadUnlockedSet() {
        XCTAssertEqual(mockDatabase.loadCalls, 1)
    }
    
    func test_loadValues_ShouldCallDatabaseLoad() {
        sut.loadDatabaseLevelsStates(from: .UserDefaults)
        
        XCTAssertEqual(mockDatabase.loadCalls, 2)
        XCTAssertEqual(mockDatabase.saveCalls, 0)
    }
    
    func test_saveValues_ShouldCallDatabaseSave() {
        sut.saveDatabaseLevelsStates(to: .UserDefaults)
        
        XCTAssertEqual(mockDatabase.loadCalls, 1)
        XCTAssertEqual(mockDatabase.saveCalls, 1)
    }
    
    
    
    func test_Shared_StagesKeys_ShouldBeEqualToIndices() {
        for (index,stage) in LevelsLibraryModel.Shared.stages.enumerated() {
            XCTAssertEqual(stage.key, index)
        }
    }

    func test_Shared_StagesIds_ShouldBeUnique() {
        let stages = LevelsLibraryModel.Shared.stages
        let uniqueIds = Set<InvariantId>(stages.map{ $0.id })
        
        XCTAssertEqual(uniqueIds.count, stages.count)
    }

    
    func test_Shared_LevelsKeys_ShouldBeEqualToIndices() {
        let stages = LevelsLibraryModel.Shared.stages

        for stage in stages {
            for (index,level) in stage.levels.enumerated() {
                XCTAssertEqual(level.key.level, index)
            }
        }
    }

    func test_Shared_StageKeyOfLevels_ShouldBeEqual() {
        let stages = LevelsLibraryModel.Shared.stages

        for stage in stages {
            for level in stage.levels {
                XCTAssertEqual(level.key.stage, stage.key)
            }
        }
    }

    func test_Shared_LevelsIds_ShouldBeUnique() {
        let stages = LevelsLibraryModel.Shared.stages
        let uniqueIds = Set<InvariantId>(stages.flatMap{ $0.levels.map{ $0.id } })
        
        XCTAssertEqual(uniqueIds.count, stages.reduce( 0, { $0 + $1.levels.count }))
    }


    func test_GameReward_sameCase() {
        let cases1 = [
            GameReward.LevelCompleted
            , GameReward.NewBestScore
            , GameReward.NewImage(nil)
            , GameReward.NewLevelUnlocked(LevelKey(stage: TestsValues.Int, level: TestsValues.Int))
            , GameReward.NewStageUnlocked(TestsValues.Int)
            , GameReward.NewUnknownImage
        ]
        let cases2 = cases1.map{
            switch($0) {
            case .NewImage(_):
                return GameReward.NewImage(TestsValues.String)
            case .NewUnknownImage:
                return GameReward.NewUnknownImage
            case .LevelCompleted:
                return GameReward.LevelCompleted
            case .NewLevelUnlocked(_):
                return GameReward.NewLevelUnlocked(LevelKey(stage: TestsValues.Int2, level: TestsValues.Int2))
            case .NewStageUnlocked(_):
                return GameReward.NewStageUnlocked(TestsValues.Int2)
            case .NewBestScore:
                return GameReward.NewBestScore
            }
        }
        
        cases1.enumerated().forEach{
            case1 in
            XCTAssertEqual(cases2.filter{ $0.sameCase(as: case1.element)}.count, 1)
            XCTAssertEqual(cases2.firstIndex(where: { $0.sameCase(as: case1.element)}), case1.offset)
        }
    }
}
