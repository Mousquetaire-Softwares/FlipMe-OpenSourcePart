//
//  GametablePlayingEngineViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation


protocol PlayingEngineViewModelDelegate : AnyObject {
    func gametableHasANewMatch(_:Set<CardViewModel.Key>)
    func gametableCardsUpdated(_:Set<CardViewModel.Key>)
    func gametableRoundIsOver(playedKeys:Set<CardViewModel.Key>,scoreEffects:[ScoreEffectViewModel])
    func gametableIsEmpty()
}


protocol PlayingEngineViewModelProtocol : AnyObject {
    var gametable:GametableViewModelProtocol { get }
    var delegate:PlayingEngineViewModelDelegate? { get set }
    
    func faceUp(_:CardViewModel.Key) throws
    func putUnmatchedCardsNotFaceUpIfRoundIsOver() throws
    var numberOfCardsToPlay : Int { get }
}
