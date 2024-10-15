//
//  GametableSinglePlayingViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation



protocol SinglePlayingViewModelProtocol : PlayingEngineViewModelProtocol {
    var scoreEngine:ScoreEngineViewModelProtocol? { get }
    func putMatchedCardsOutOfGame() throws
}

enum SinglePlayingViewModelError : Error {
    case KeyDoesntExist
    case IncorrectGametableState
}

class SinglePlayingViewModel : SinglePlayingViewModelProtocol {
    init(gametable: GametableViewModelProtocol
         ,scoreEngine: ScoreEngineViewModelProtocol? = nil)
    {
        self.scoreEngine = scoreEngine
        self.gametable = gametable
    }
    
    var gametable: GametableViewModelProtocol
    weak var delegate: PlayingEngineViewModelDelegate?

    var numberOfCardsToPlay: Int {
        gametable.cards.filter{ $0.value.isMatched == false }.count
    }
    
    var scoreEngine: ScoreEngineViewModelProtocol?
    
    func putMatchedCardsOutOfGame() throws {
        let cards = gametable.cards
        let targetCardKeys = cards.keys.filter{
            cards[$0]?.isMatched == true && cards[$0]?.isOutOfGame == false
        }
        targetCardKeys.forEach{ gametable.cards[$0]?.isOutOfGame = true }
        if !targetCardKeys.isEmpty {
            delegate?.gametableCardsUpdated(Set(targetCardKeys))
        }
    }
    
    var gametableLock : NSLock = NSLock()
    func faceUp(_ key: CardViewModel.Key) throws {
        try gametableLock.withLock {
            guard gametable.cards.keys.contains(key) else { throw SinglePlayingViewModelError.KeyDoesntExist }
            
            try putUnmatchedCardsNotFaceUpIfRoundIsOver()
            
            try putMatchedCardsOutOfGame()
            
            if gametable.cards[key]?.isFaceUp == false {
                gametable.cards[key]?.isFaceUp = true
                
                // delegates calls - one card is faced up
                scoreEngine?.cardIsFacingUp(key, gametable: gametable)
                delegate?.gametableCardsUpdated([key])
                
                // Check if this is the end of a round
                let endOfRoundKeys = gametable.unmatchedAndFacedUpCardsKeys
                if endOfRoundKeys.count >= gametable.cardsByMatch {
                    // get complete KeyValues of the round cards
                    let targetKeysValues = try endOfRoundKeys.map{
                        if let keyValue = gametable[$0] { return keyValue }
                        else { throw SinglePlayingViewModelError.KeyDoesntExist }
                    }
                    
                    let matchesFound : Int
                    let endOfGame : Bool
                    // check if there's a match
                    if !GametableViewModel.cardsMatches(targetKeysValues) {
                        matchesFound = 0
                        endOfGame = false
                    } else {
                        matchesFound = 1
                        
                        try endOfRoundKeys.forEach {
                            if gametable.cards[$0] != nil {
                                gametable.cards[$0]!.isMatched = true
                            } else {
                                throw SinglePlayingViewModelError.KeyDoesntExist
                            }
                        }
                        // delegate calls - updated cards for a new match
                        delegate?.gametableCardsUpdated(endOfRoundKeys)
                        delegate?.gametableHasANewMatch(endOfRoundKeys)
                        
                        endOfGame = numberOfCardsToPlay == 0
                    }
                    
                    // delegates calls - end of a round
                    let scoreEffects = scoreEngine?.roundIsOver(matchesFound: matchesFound
                                                                , roundPlayedCards:endOfRoundKeys
                                                                , gametable: gametable)
                    delegate?.gametableRoundIsOver(playedKeys: endOfRoundKeys, scoreEffects: scoreEffects ?? [])
                    
                    // delegates calls - end of game
                    if endOfGame {
                        try putMatchedCardsOutOfGame()
                        scoreEngine?.gameIsOver()
                        delegate?.gametableIsEmpty()
                    }
                }
            }
        }
    }
    
    func putUnmatchedCardsNotFaceUpIfRoundIsOver() throws {
        let targetCardKeys = gametable.unmatchedAndFacedUpCardsKeys
        if targetCardKeys.count >= gametable.cardsByMatch {
            targetCardKeys.forEach{ gametable.cards[$0]?.isFaceUp = false }
            // delegates calls
            scoreEngine?.cardsAreFacingDown(targetCardKeys,gametable: gametable)
            delegate?.gametableCardsUpdated(targetCardKeys) //game: gametable)
        }
    }
    
    
}
