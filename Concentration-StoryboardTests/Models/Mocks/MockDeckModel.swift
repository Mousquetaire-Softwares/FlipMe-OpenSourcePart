//
//  DeckModelMock.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 18/01/2024.
//

import XCTest

@testable import FlipMe_OpenSource

struct MockDeckModel: DeckModelProtocol {
    var colorsLibrary: [CGColor] = DeckModelBuilder.UIParameter.CardBackgroundColors
    
    mutating func newDeal(renewingImages: Bool) {

    }
    
    var remainingMatchingCardsModels: Int = 99
    
    var mockedPopRandomMatchingCardsModel: MatchingCardsModel? = MatchingCardsModel(image: .Single(imageName: "test"))
    var mockedPopRandomMatchingCardsModelResults = [MatchingCardsModel?]()
    
    mutating func getUniqueMatchingCardsModel() -> MatchingCardsModel? {
        let result : MatchingCardsModel?
        if remainingMatchingCardsModels == 0 {
            result = nil
        } else {
            remainingMatchingCardsModels -= 1
            result = mockedPopRandomMatchingCardsModel
        }
        mockedPopRandomMatchingCardsModelResults.append(result)
        return result
    }
}
