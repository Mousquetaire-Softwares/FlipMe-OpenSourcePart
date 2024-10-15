//
//  PlayingEngineViewModelDelegateMock.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 18/01/2024.
//

import Foundation
@testable import Concentration_Storyboard

class MockPlayingEngineViewModelDelegate : PlayingEngineViewModelDelegate {
    private(set) var gametableHasANewMatchCalls = [Set<Concentration_Storyboard.CardViewModel.Key>]()
    private(set) var gametableCardsUpdatedCalls = [Set<Concentration_Storyboard.CardViewModel.Key>]()
    private(set) var gametableRoundIsOverCalls : [(Set<Concentration_Storyboard.CardViewModel.Key>,[ScoreEffectViewModel])] = []
    private(set) var gametableIsEmptyCalls : Int = 0
    
    func gametableHasANewMatch(_ arg: Set<CardViewModel.Key>) {
        gametableHasANewMatchCalls.append(arg)
    }
    
    func gametableCardsUpdated(_ arg: Set<CardViewModel.Key>) {
        gametableCardsUpdatedCalls.append(arg)
    }
    
    func gametableRoundIsOver(playedKeys arg1: Set<Concentration_Storyboard.CardViewModel.Key>,scoreEffects arg2: [ScoreEffectViewModel]) {
        gametableRoundIsOverCalls.append((arg1,arg2))
    }
    
    func gametableIsEmpty() {
        gametableIsEmptyCalls += 1
    }
}
