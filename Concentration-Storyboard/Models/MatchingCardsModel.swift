//
//  MatchingCardsModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 05/01/2024.
//

import Foundation
import CoreGraphics

typealias MatchingCardsId = Int

enum CardImage : Equatable {
    case Single(imageName:String)
    case Double(imageName1:String, imageName2:String)
}

class MatchingCardsModel : Equatable, Hashable {
    
    static func == (lhs: MatchingCardsModel, rhs: MatchingCardsModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let image:CardImage
    let id:MatchingCardsId
    let backColor:CGColor
    
    private static var identifierFactory : MatchingCardsId = 0
    private static func getUniqueIdentifier() -> MatchingCardsId {
        identifierFactory += 1
        return identifierFactory
    }
    
    init(image:CardImage, backColor:CGColor = DeckModelBuilder.UIParameter.CardBackgroundColorDefault) {
        self.id = Self.getUniqueIdentifier()
        self.image = image
        self.backColor = backColor
    }
}
