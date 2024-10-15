//
//  StageViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 26/02/2024.
//

import Foundation

protocol StageViewModelProtocol {
    typealias CardExample = [CardViewModel]

    var key : StageKey { get }
    var cardsByMatch : Int? { get }
    var playersCount : Int { get }
    
    func generateCardsExamples() -> [CardExample]
}


struct StageViewModel : StageViewModelProtocol {
    
    init(model: StageModelProtocol, usingForCardsExamples imagesPicker: ImagesLibraryPickerModelProtocol) {
        self.key = model.key
        self.cardsByMatch = model.cardsByMatch
        self.cardsType = model.cardsType
        self.imagesPicker = imagesPicker
        
        if let playingMode = model.gamePlayingMode {
            switch(playingMode) {
            case .MultiPlayer: 
                playersCount = 2
            case .SinglePlayer:
                fallthrough
            case .SinglePlayerTimeLimited(_):
                playersCount = 1
            }
        } else {
            playersCount = 0
        }
        

    }
    
    let key: StageKey
    let cardsByMatch : Int?
    let playersCount: Int
    let cardsType : CardType?
    private let imagesPicker : ImagesLibraryPickerModelProtocol
    
    // list of fictive cards to show to the user an example of what kind of matching cards will fill the gametable
    func generateCardsExamples() -> [CardExample] {
        if let cardsType, let cardsByMatch {
            var deck = DeckModelBuilder.CreateDeck(for: cardsType, using: imagesPicker)
            var fictiveCards : [CardViewModel]? = []
            
            if deck.remainingMatchingCardsModels < 3 {
                deck.newDeal(renewingImages: true)
            }
            
            func addFictiveCard() {                    
                if fictiveCards != nil
                    , let matchingCard = deck.getUniqueMatchingCardsModel()
                {
                    fictiveCards?.append(CardViewModel(matchingCardsModel: matchingCard
                                                       , location: Location2D(row: 0, column: 0)))
                } else {
                    fictiveCards = nil
                }
            }
            
            switch(cardsType) {
            case .SingleImage:
                addFictiveCard()
            case .SingleImageMultiColors(let colorsCount):
                for _ in 0..<colorsCount {
                    addFictiveCard()
                }
            case .DualImage:
                addFictiveCard()
            case .DualImageMultiOrder:
                addFictiveCard()
                addFictiveCard()
            }
            
            if let fictiveCards {
                return fictiveCards.map{ [CardViewModel](repeating: $0, count: cardsByMatch) }
            } else {
                return []
            }
        } else {
            return []
        }
        
    }
    
}
