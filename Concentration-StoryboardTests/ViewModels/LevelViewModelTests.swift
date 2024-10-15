//
//  LevelViewModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 08/02/2024.
//

import XCTest
@testable import Concentration_Storyboard

extension GameProcessViewModel {
    func sameCase(as other:GameProcessViewModel) -> Bool {
        func getCaseNum(case:GameProcessViewModel) -> Int {
            let result : Int
            switch(self) {
            case .NotInitialized:
                result = 0
            case .Dealing(_):
                result = 1
            case .Playing(_):
                result = 2
            }
            return result
        }
        return getCaseNum(case: self) == getCaseNum(case: other)
    }
}

final class LevelViewModelTests: XCTestCase {
    var sut : LevelViewModel!
    var mockDealerDelegate: MockDealerViewModelDelegate!
    var mockPlayingEngineDelegate: MockPlayingEngineViewModelDelegate!
    var mockDealerEmpty: MockDealerViewModelEmpty!
    var mockPlayingEngineEmpty: MockPlayingEngineViewModelEmpty!
    
    override func setUpWithError() throws {
        let deck = MockDeckModel()
        mockDealerDelegate = MockDealerViewModelDelegate()
        mockPlayingEngineDelegate = MockPlayingEngineViewModelDelegate()
        mockDealerEmpty = MockDealerViewModelEmpty()
        mockPlayingEngineEmpty = MockPlayingEngineViewModelEmpty()
        let mockLevel = MockLevelModel(key: LevelKey(stage:0, level:0)
                                       , unlocked: true
                                       , cardsToDeal: 10
                                       , cardsByMatch: 2
                                       , userCanDealCards: false
                                       , cardsType: .SingleImage
                                       , gamePlayingMode: .SinglePlayer)
        sut = LevelViewModel(model:mockLevel
                             , using: deck)
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mockDealerDelegate = nil
        mockPlayingEngineDelegate = nil
    }

    func test_Initializing() {
        XCTAssertTrue(sut.gameProcess.sameCase(as:.NotInitialized))
        XCTAssertNil(sut.gameProcess.gametable)
    }
    
    func test_StartNewGame() {
        sut.startNewGame()
        XCTAssertTrue(sut.gameProcess.sameCase(as:.Dealing(mockDealerEmpty)))
        XCTAssertNotNil(sut.gameProcess.gametable)
    }
    
    func test_SetGamePlaying_NotInitialized() {
        sut.setGamePlaying()
        XCTAssertTrue(sut.gameProcess.sameCase(as: .Playing(mockPlayingEngineEmpty)))
        XCTAssertNotNil(sut.gameProcess.gametable)
    }
    
    func test_SetGamePlaying_Dealing() {
        sut.startNewGame()
        sut.setGamePlaying()
        XCTAssertTrue(sut.gameProcess.sameCase(as: .Playing(mockPlayingEngineEmpty)))
        XCTAssertNotNil(sut.gameProcess.gametable)
    }
    
    func test_SetGamePlaying_Playing() {
        sut.startNewGame()
        sut.setGamePlaying()
        sut.setGamePlaying()
        XCTAssertTrue(sut.gameProcess.sameCase(as: .Playing(mockPlayingEngineEmpty)))
        XCTAssertNotNil(sut.gameProcess.gametable)
    }
}
