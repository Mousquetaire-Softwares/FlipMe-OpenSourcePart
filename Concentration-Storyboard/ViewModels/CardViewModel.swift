//
//  CardViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 06/01/2024.
//

import Foundation
import CoreGraphics

typealias CardViewModelIndex = Int


struct CardViewModel : Equatable {
    typealias Key = Int
    typealias KeyValue = (key:Key,value:CardViewModel)

    internal init(matchingCardsModel: MatchingCardsModel
                  , location: Location2D
                  , isMatched: Bool = false
                  , isFaceUp: Bool = false
                  , isOutOfGame: Bool = false)
    {
        self.matchingCardsModel = matchingCardsModel
        self.location = location
        self.isMatched = isMatched
        self.isFaceUp = isFaceUp
        self.isOutOfGame = isOutOfGame
    }
    
    typealias MatchingId = MatchingCardsId
    
   // Model related data
    private let matchingCardsModel : MatchingCardsModel
    var image : CardImage { matchingCardsModel.image }
    var matchingId : MatchingId { matchingCardsModel.id }
    

    // ViewModel related data
    var location:Location2D

     // default values
    var color : CGColor? { matchingCardsModel.backColor }
    var isMatched = false
    var isFaceUp = false
    var isOutOfGame = false

}

extension CardViewModel {
    struct UIParameter {
        static let CoverImageDefault : ImageName = "cover-001"
    }
}
