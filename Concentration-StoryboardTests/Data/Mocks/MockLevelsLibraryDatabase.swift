//
//  MockLevelsLibraryDatabase.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 24/04/2024.
//

import Foundation
@testable import Concentration_Storyboard

class MockLevelsLibraryDatabase : LevelsLibraryDatabaseProtocol {
    
    var stagesParameters: [GameDatabase.StageParameters] = []
    var levelsUnlockedIds: Set<InvariantId> = []
    var levelsPoints: [InvariantId : Float] = [:]
    var levelsBestScores: [InvariantId : Float] = [:]
    
    
    
    private(set) var loadCalls = 0
    func load(from location: GameDatabase.UserDataLocation) {
        loadCalls += 1
    }
    private(set) var saveCalls = 0
    func save(to location: GameDatabase.UserDataLocation) {
        saveCalls += 1
    }
}
