//
//  MockPlayingEngineViewModel.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 08/02/2024.
//

import Foundation
@testable import FlipMe_OpenSource

class MockPlayingEngineViewModelEmpty : PlayingEngineViewModelProtocol {
    
    var gametable: GametableViewModelProtocol = MockGametableViewModelEmpty()
    
    var delegate: PlayingEngineViewModelDelegate? = nil
    
    func faceUp(_: CardViewModel.Key) throws {
        
    }
    
    func putUnmatchedCardsNotFaceUpIfRoundIsOver() throws {
        
    }
    
    var numberOfCardsToPlay: Int = 0
    
    
}
