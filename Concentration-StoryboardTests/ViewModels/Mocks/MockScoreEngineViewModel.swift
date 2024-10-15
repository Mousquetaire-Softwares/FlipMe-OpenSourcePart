//
//  ScoreEngineViewModelMock.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 18/01/2024.
//

import Foundation
@testable import FlipMe_OpenSource

class MockScore : GameScoreModelProtocol {
    var score: Float = 0
    
    var points: Float = 0
    
    var rank: ScoreRank = .Zero
    
}

class MockScoreEngineViewModel : ScoreEngineViewModelProtocol {
    var score : GameScoreModelProtocol = MockScore()
    
    
    private(set) var cardIsFacingUpCalls = [(arg1:CardViewModel.Key, gametable: GametableViewModelProtocol)]()
    private(set) var cardsAreFacingDownCalls = [(arg1:Set<CardViewModel.Key>, gametable: GametableViewModelProtocol)]()
    private(set) var roundIsOverCalls = [(matchesFound:Int, roundPlayedCards: Set<CardViewModel.Key>, gametable: GametableViewModelProtocol)]()
    private(set) var gameIsOverCalls = 0
        func cardIsFacingUp(_ arg1: CardViewModel.Key, gametable: GametableViewModelProtocol) {
            cardIsFacingUpCalls.append((arg1:arg1, gametable: gametable))
    }
    
    func cardsAreFacingDown(_ arg1: Set<CardViewModel.Key>, gametable: GametableViewModelProtocol) {
        cardsAreFacingDownCalls.append((arg1:arg1, gametable: gametable))
    }
    
    var roundIsOverReturnValue = [ScoreEffectViewModel]()
    func roundIsOver(matchesFound: Int
                     , roundPlayedCards: Set<CardViewModel.Key>
                     , gametable: GametableViewModelProtocol)
    -> [ScoreEffectViewModel]
    {
        roundIsOverCalls.append((matchesFound:matchesFound, roundPlayedCards: roundPlayedCards, gametable: gametable))
        return roundIsOverReturnValue
    }
    
    func gameIsOver() {
        gameIsOverCalls += 1
    }
    
    var roundCount: Int = 0
    
}
