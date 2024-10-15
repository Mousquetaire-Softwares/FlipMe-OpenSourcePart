//
//  SingleImageDeckModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 06/02/2024.
//

import Foundation
import CoreGraphics

struct SingleImageDeckModel : DeckModelProtocol {
    init(imagesPicker:ImagesLibraryPickerModelProtocol
         , differentBackgroundColorsInADeal colorsByDeal: Int = 1
         , colorsLibrary:[CGColor] = DeckModelBuilder.UIParameter.CardBackgroundColors) 
    {
        self.imagesPicker = imagesPicker
        self.colorsLibrary = colorsLibrary
        self.colorsByDeal = min(colorsByDeal, colorsLibrary.count)
        imagesCategory = self.colorsByDeal > 1 ? .ImageForMulticolorBackground : .AnyImage
    }
    
    private var imagesPicker : ImagesLibraryPickerModelProtocol
    private let imagesCategory : ImageCategory
    private let colorsByDeal:Int
    
    let colorsLibrary:[CGColor]
    
    
    // for multi background colors only
    private lazy var colorsOfCurrentDeal : [CGColor] = getColorsForNewDeal()
    private mutating func resetColorsOfCurrentDeal() {
        colorsOfCurrentDeal = getColorsForNewDeal()
    }
    private func getColorsForNewDeal() -> [CGColor] {
        randomSetOfColors(numberOfColors: colorsByDeal)
    }
    private var matchingCardsToDeliver : [MatchingCardsModel] = []
    
    
    mutating func getUniqueMatchingCardsModel() -> MatchingCardsModel? {
        // if multi color mode : we use a private array to prepare many matching cards with the same image
        if colorsByDeal > 1 {
            if matchingCardsToDeliver.isEmpty {
                if let newImageName = imagesPicker.popRandom(for:imagesCategory) {
                    matchingCardsToDeliver = colorsOfCurrentDeal.map{
                        MatchingCardsModel(image: .Single(imageName: newImageName), backColor: $0)
                    }
                }
            }
            matchingCardsToDeliver.shuffle()
            return matchingCardsToDeliver.popLast()
        } else {
            if let newImageName = imagesPicker.popRandom(for:imagesCategory)
                , let backColor = colorsOfCurrentDeal.first 
            {
                return MatchingCardsModel(image: .Single(imageName: newImageName), backColor: backColor)
            } else {
                return nil
            }
        }
    }
    
    
    
    mutating func newDeal(renewingImages:Bool) {
        imagesPicker.reset(renewingImages: renewingImages)
        resetColorsOfCurrentDeal()
    }
    
    var remainingMatchingCardsModels: Int {
        get {
            imagesPicker.remainingCount(for:imagesCategory)
        }
    }
}
