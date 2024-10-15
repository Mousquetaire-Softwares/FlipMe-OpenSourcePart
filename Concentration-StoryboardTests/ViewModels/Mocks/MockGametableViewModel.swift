//
//  GametableViewModelMock.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 18/01/2024.
//

import Foundation
@testable import Concentration_Storyboard

struct MockGametableViewModel : GametableViewModelProtocol {
    mutating func shuffleCardsLocations() {
        
    }
    
    var cards: [CardViewModel.Key : CardViewModel]
    
    var cardsByMatch: Int
    
    var size: Size2D
}
    

struct MockGametableViewModelEmpty : GametableViewModelProtocol {
    mutating func shuffleCardsLocations() {
        
    }
    
    var cards: [CardViewModel.Key : CardViewModel] = [:]
    
    var cardsByMatch: Int = 2
    
    var size: Size2D = Size2D(rows: 0, columns: 0)
}
