//
//  PlayingEngineViewModelDelegateMock.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 18/01/2024.
//

import Foundation
@testable import FlipMe_OpenSource

class MockPlayingEngineViewModelDelegate : PlayingEngineViewModelDelegate {
    private(set) var gametableHasANewMatchCalls = [Set<FlipMe_OpenSource.CardViewModel.Key>]()
    private(set) var gametableCardsUpdatedCalls = [Set<FlipMe_OpenSource.CardViewModel.Key>]()
    private(set) var gametableRoundIsOverCalls : [(Set<FlipMe_OpenSource.CardViewModel.Key>,[ScoreEffectViewModel])] = []
    private(set) var gametableIsEmptyCalls : Int = 0
    
    func gametableHasANewMatch(_ arg: Set<CardViewModel.Key>) {
        gametableHasANewMatchCalls.append(arg)
    }
    
    func gametableCardsUpdated(_ arg: Set<CardViewModel.Key>) {
        gametableCardsUpdatedCalls.append(arg)
    }
    
    func gametableRoundIsOver(playedKeys arg1: Set<FlipMe_OpenSource.CardViewModel.Key>,scoreEffects arg2: [ScoreEffectViewModel]) {
        gametableRoundIsOverCalls.append((arg1,arg2))
    }
    
    func gametableIsEmpty() {
        gametableIsEmptyCalls += 1
    }
}
