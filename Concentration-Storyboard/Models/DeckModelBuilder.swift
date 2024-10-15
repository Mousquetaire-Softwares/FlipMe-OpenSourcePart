//
//  DeckModelBuilder.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 26/02/2024.
//

import Foundation
import CoreGraphics

class DeckModelBuilder {
    static func CreateDeck(for cardsType:CardType
                           , using imagesPicker:ImagesLibraryPickerModelProtocol) -> DeckModelProtocol {
        
        switch(cardsType) {
        case .SingleImage:
            return SingleImageDeckModel(imagesPicker: imagesPicker
                                        , colorsLibrary: [UIParameter.CardBackgroundColorDefault])
        case .SingleImageMultiColors(colorsCount: let requestedColors):
            return SingleImageDeckModel(imagesPicker: imagesPicker
                                        , differentBackgroundColorsInADeal: requestedColors)
        case .DualImage:
            return DoubleImageDeckModel(imagesPicker: imagesPicker
                                        , colorsLibrary: [UIParameter.CardBackgroundColorDefault]
                                        , doubleOrderForEachPairOfImages: false)
        case .DualImageMultiOrder:
            return DoubleImageDeckModel(imagesPicker: imagesPicker
                                        , colorsLibrary: [UIParameter.CardBackgroundColorDefault]
                                        , doubleOrderForEachPairOfImages: true)
        }
    }
}

extension DeckModelBuilder {
    struct UIParameter {
        static let CardBackgroundColors  : [CGColor] = [
            #colorLiteral(red: 0.948007171, green: 0.9687105429, blue: 0.9490446346, alpha: 1),
            #colorLiteral(red: 1, green: 0.903345339, blue: 0.5298934725, alpha: 1),
            #colorLiteral(red: 0.5066065687, green: 0.6803212176, blue: 1, alpha: 1),
            #colorLiteral(red: 0.8708175505, green: 0.6456129141, blue: 0.620631797, alpha: 1),
            #colorLiteral(red: 0.5465057767, green: 0.7032433712, blue: 0.499325865, alpha: 1)
        ]
        static let CardBackgroundColorDefault : CGColor = #colorLiteral(red: 1, green: 0.903345339, blue: 0.5298934725, alpha: 1)

    }
}
