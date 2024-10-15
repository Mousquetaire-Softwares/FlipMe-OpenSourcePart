//
//  DeckModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation
import CoreGraphics

protocol DeckModelProtocol {
    mutating func getUniqueMatchingCardsModel() -> MatchingCardsModel?
    mutating func newDeal(renewingImages:Bool)
    var remainingMatchingCardsModels : Int { get }
    var colorsLibrary:[CGColor] { get }
}

extension DeckModelProtocol {
    func randomSetOfColors(numberOfColors requestedNumber:Int) -> [CGColor] {
        let finalNumber = min(requestedNumber,colorsLibrary.count)
        if finalNumber < 1 {
            return []
        } else {
            return [CGColor](colorsLibrary.shuffled()[0..<finalNumber])
        }
    }
}
