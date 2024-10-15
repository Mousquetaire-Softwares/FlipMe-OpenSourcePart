//
//  GametableMultiPlayingViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation

typealias PlayerId = Int

protocol MultiPlayingViewModelProtocol : PlayingEngineViewModelProtocol {
    func putMatchedCardsOutOfGame(matchingCardsId:MatchingCardsId, wonByPlayer:PlayerId) throws
}

class MultiPlayingViewModel : MultiPlayingViewModelProtocol {
    init(gametable: GametableViewModelProtocol
          ,players: Set<PlayerId>)
    {
        self.gametable = gametable
        self.players = players
    }
    
    private(set) var players : Set<PlayerId>
    var gametable: GametableViewModelProtocol
    weak var delegate: PlayingEngineViewModelDelegate?
    
    var numberOfCardsToPlay: Int = 0
    

    func putMatchedCardsOutOfGame(matchingCardsId: MatchingCardsId, wonByPlayer: PlayerId) throws {
//        <#code#>
    }
    
    func faceUp(_: CardViewModel.Key) throws {
//        <#code#>
    }
    
    func putUnmatchedCardsNotFaceUpIfRoundIsOver() throws { //}-> Set<CardViewModel.Key> {
//        <#code#>
    }
    

    
    
}
