//
//  StageModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 09/02/2024.
//

import Foundation

protocol StageModelProtocol {
    var key : StageKey { get }
    var id : InvariantId { get }
    
    var levels : [LevelModelProtocol] { get set }
    
    // game characteristics - can be undefined for stages
    var cardsByMatch : Int? { get }
    var cardsToDeal : Int? { get }
    var userCanDealCards: Bool? { get }
    var cardsType : CardType? { get }
    var gamePlayingMode : GamePlayingMode? { get }
}

struct StageModel : StageModelProtocol {
    let key: StageKey
    let id: InvariantId
    
    var levels : [LevelModelProtocol]
    
    // game characteristics - only defined when all the stages have the same value
    var cardsByMatch: Int? {
        let uniqueValuesInLevels = Set<Int>(levels.map{$0.cardsByMatch})
        return uniqueValuesInLevels.count > 1 ? nil : uniqueValuesInLevels.first
    }
    var cardsToDeal: Int? {
        let uniqueValuesInLevels = Set<Int>(levels.map{$0.cardsToDeal})
        return uniqueValuesInLevels.count > 1 ? nil : uniqueValuesInLevels.first
    }
    var userCanDealCards: Bool? {
        let uniqueValuesInLevels = Set<Bool>(levels.map{$0.userCanDealCards})
        return uniqueValuesInLevels.count > 1 ? nil : uniqueValuesInLevels.first
    }
    var cardsType: CardType? {
        let uniqueValuesInLevels = Set<CardType>(levels.map{$0.cardsType})
        return uniqueValuesInLevels.count > 1 ? nil : uniqueValuesInLevels.first
    }
    var gamePlayingMode: GamePlayingMode? {
        let uniqueValuesInLevels = Set<GamePlayingMode>(levels.map{$0.gamePlayingMode})
        return uniqueValuesInLevels.count > 1 ? nil : uniqueValuesInLevels.first
    }
    
    
}
