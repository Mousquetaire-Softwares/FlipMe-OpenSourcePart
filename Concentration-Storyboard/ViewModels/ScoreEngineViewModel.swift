//
//  ScoreEngineViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation


protocol ScoreEngineViewModelProtocol {
    mutating func cardIsFacingUp(_:CardViewModel.Key,gametable:GametableViewModelProtocol)
    mutating func cardsAreFacingDown(_:Set<CardViewModel.Key>,gametable:GametableViewModelProtocol)
    mutating func roundIsOver(matchesFound:Int,roundPlayedCards:Set<CardViewModel.Key>,gametable:GametableViewModelProtocol) -> [ScoreEffectViewModel]
    mutating func gameIsOver()
    
    var roundCount : Int { get }
    var score : GameScoreModelProtocol { get }
}

struct ScoreEngineViewModel : ScoreEngineViewModelProtocol {
    internal init(numberOfCards: Int, cardsByMatch: Int) {
        self.numberOfCards = numberOfCards
        self.cardsByMatch = cardsByMatch
        self.privateScore = GameScoreModel(numberOfCards: numberOfCards
                                           , cardsByMatch: cardsByMatch)
    }
    
    
    
    var score : GameScoreModelProtocol { privateScore }
    private var privateScore : GameScoreModel
    

    private var unknownKeys : Set<CardViewModel.Key>? = nil
    mutating func cardIsFacingUp(_ key: CardViewModel.Key, gametable: GametableViewModelProtocol) {
        playedCards.append(key)
        if unknownKeys == nil {
            unknownKeys = Set<CardViewModel.Key>(gametable.cards.keys)
        }
        unknownKeys?.remove(key)
    }
    
    mutating func cardsAreFacingDown(_: Set<CardViewModel.Key>, gametable: GametableViewModelProtocol) {
    }
    
    private var currentRoundCardKeys : ArraySlice<CardViewModel.Key> {
        if playedCards.count > 0 {
//            let numberOfCardsPlayedThisRound = ((playedCards.count-1) % cardsByMatch) + 1
            return playedCards[(playedCards.endIndex-1)...]
        } else {
            return []
        }
    }
    
    mutating func roundIsOver(matchesFound: Int, roundPlayedCards: Set<CardViewModel.Key>, gametable: GametableViewModelProtocol) -> [ScoreEffectViewModel] {
        roundCount += 1
        var effects = [ScoreEffectViewModel]()
        
        if matchesFound > 0 {
            let consecutiveMatches = previousRoundConsecutiveMatch + matchesFound

            // if there is many consecutive matches, we should record it into the score model
            if consecutiveMatches == 2 {
                // New series of consecutive matches
                privateScore.seriesOfConsecutiveMatches.append(consecutiveMatches)
            } else if consecutiveMatches > 2 {
                privateScore.seriesOfConsecutiveMatches.removeLast()
                privateScore.seriesOfConsecutiveMatches.append(consecutiveMatches)
            }
            
            // Lucky Match or Not
            if lastPlayedCardWasNeverPlayedBefore() && thereIsCardsNeverPlayed() {
                effects.append(.LuckyMatch(consecutiveMatches: consecutiveMatches))
            } else {
                effects.append(.Match(consecutiveMatches: consecutiveMatches))
            }
            
            previousRoundConsecutiveMatch = consecutiveMatches
        } else {
            // Series of consecutive matches had been broken
            if previousRoundConsecutiveMatch > 1 {
                effects.append(.ConsecutivesMatchesLost(previousMatches: previousRoundConsecutiveMatch))
            }
            previousRoundConsecutiveMatch = 0
            
            // Bad moves detection
            if previousRoundPlayedCards.intersection(roundPlayedCards).isEmpty == false {
                privateScore.badMoves += 1
                effects.append(.BadMove)
            }
        }
        
        previousRoundPlayedCards.formUnion(roundPlayedCards)
        return effects
    }
    
    private func lastPlayedCardWasNeverPlayedBefore() -> Bool {
        (playedCards.filter{ $0 == self.playedCards.last }.count == 1)
    }
    private func thereIsCardsNeverPlayed() -> Bool {
        !(unknownKeys?.isEmpty ?? false)
    }
    
    
    mutating func gameIsOver() {
    }
    

    let numberOfCards : Int
    private let cardsByMatch : Int
    
    private(set) var roundCount : Int = 0
    
    private var playedCards = [CardViewModel.Key]()
    private var previousRoundPlayedCards = Set<CardViewModel.Key>()
    private var previousRoundConsecutiveMatch : Int = 0
    
}
