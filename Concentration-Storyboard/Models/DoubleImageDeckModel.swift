//
//  DoubleImageDeckModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 10/02/2024.
//

import Foundation
import CoreGraphics

struct DoubleImageDeckModel : DeckModelProtocol {
    init(imagesPicker:ImagesLibraryPickerModelProtocol
         , colorsLibrary:[CGColor] = DeckModelBuilder.UIParameter.CardBackgroundColors
         , doubleOrderForEachPairOfImages:Bool) 
    {
        self.imagesPicker = imagesPicker
        self.colorsLibrary = colorsLibrary

        self.doubleOrder = doubleOrderForEachPairOfImages
        self.imagesCategory = doubleOrder ? .ImageForCardsWithDoubleImagesDoubleOrder : .ImageForCardsWithDoubleImages
    }
    
    private var imagesPicker : ImagesLibraryPickerModelProtocol
    private let imagesCategory : ImageCategory

    let colorsLibrary:[CGColor]
    

    // for multi background colors - not implemented yet here, only one color per Deal
    private lazy var colorOfCurrentDeal : CGColor = getColorForNewDeal()
    private mutating func resetColorsOfCurrentDeal() {
        colorOfCurrentDeal = getColorForNewDeal()
    }
    private func getColorForNewDeal() -> CGColor {
        colorsLibrary.randomElement() ?? DeckModelBuilder.UIParameter.CardBackgroundColorDefault
    }
    private var matchingCardsToDeliver : [MatchingCardsModel] = []

    // Handling double image card generation
    private let doubleOrder : Bool
    private var imagesPairsToDeliver : [(ImageName,ImageName)] = []
    private var images : [ImageName] = []
    
    
    mutating func getUniqueMatchingCardsModel() -> MatchingCardsModel? {
        if images.isEmpty {
            if let newImageName = imagesPicker.popRandom(for:imagesCategory) {
                images.append(newImageName)
            }
        }
        if imagesPairsToDeliver.isEmpty {
            if let newImageName = imagesPicker.popRandom(for:imagesCategory) {
                images.forEach{
                    if doubleOrder {
                        imagesPairsToDeliver.append(($0,newImageName))
                        imagesPairsToDeliver.append((newImageName,$0))
                    } else {
                        let pair = [$0,newImageName].shuffled()
                        imagesPairsToDeliver.append((pair.first!,pair.last!))
                    }
                }
                
                images.append(newImageName)
            }
        }
        imagesPairsToDeliver.shuffle()
        
        if let newPair = imagesPairsToDeliver.popLast() {
            return MatchingCardsModel(image: .Double(imageName1: newPair.0, imageName2: newPair.1)
                                      , backColor: colorOfCurrentDeal)
        } else {
            return nil
        }
    }
    
    
    
    mutating func newDeal(renewingImages:Bool) {
        imagesPicker.reset(renewingImages: renewingImages)
        resetColorsOfCurrentDeal()
    }
    
    var remainingMatchingCardsModels: Int {
        get { imagesPicker.remainingCount(for:imagesCategory) }
    }
}
