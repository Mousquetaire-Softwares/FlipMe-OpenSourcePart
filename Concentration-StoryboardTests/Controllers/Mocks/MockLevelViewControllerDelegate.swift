//
//  MockLevelViewControllerDelegate.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 01/03/2024.
//

import Foundation
@testable import FlipMe_OpenSource

class MockLevelViewControllerDelegate : LevelViewControllerDelegate {
    func createEndOfGameViewController(levelKey: LevelKey, withFinalScore: GameScoreModelProtocol, sender: LevelViewController)  -> EndOfGameViewController? {
        nil
    }
    
    
}
