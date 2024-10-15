//
//  MockLevelViewModel.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 08/02/2024.
//

import Foundation
@testable import Concentration_Storyboard

struct MockLevelViewModel : LevelViewModelProtocol {
    var staticOrientation: Bool = false
    
//    internal init(key: LevelKey, setGamePlayingCalls: [(Void, shuffleCardsLocationsIfGameWasDealing: Bool)] = [], delegate: GameProcessViewModelDelegate? = nil, gameProcess: GameProcessViewModel, cardsByMatch: Int, cardsToDeal: Int, unlocked: Bool, userCanAddCards: Bool = false) {
//        self.privateState = privateState
//        self.key = key
//        self.startNewGameCalls = startNewGameCalls
//        self.setGamePlayingCalls = setGamePlayingCalls
//        self.delegate = delegate
//        self.gameProcess = gameProcess
//        self.cardsByMatch = cardsByMatch
//        self.cardsToDeal = cardsToDeal
//        self.unlocked = unlocked
//        self.userCanAddCards = userCanAddCards
//    }
    
    private(set) var privateState : LevelState?
    var state: LevelState {
        get { return LevelState(levelKeyForTests: self.key, unlocked: self.unlocked) }
        set { privateState = newValue }
    }
    
    var key: LevelKey
    

    private(set) var startNewGameCalls : Int = 0
    mutating func startNewGame() {
        startNewGameCalls += 1
    }
    
    private(set) var setGamePlayingCalls : [(_: Void, shuffleCardsLocationsIfGameWasDealing: Bool)] = []
    
    mutating func setGamePlaying(shuffleCardsLocationsIfGameWasDealing: Bool) {
        setGamePlayingCalls.append(((), shuffleCardsLocationsIfGameWasDealing:shuffleCardsLocationsIfGameWasDealing))
    }
    var delegate: GameProcessViewModelDelegate?

    var gameProcess: GameProcessViewModel
    
    var cardsByMatch: Int
    
    var cardsToDeal: Int

    var unlocked: Bool
    
    var userCanAddCards: Bool = false
}
