//
//  GametableLegacyViewModelDealer.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation

protocol DealerViewModelProtocol : AnyObject {
    var gametable:GametableViewModelProtocol { get }
    var delegate : DealerViewModelDelegate? { get set }
    func addCardsInGametable(expandingDirection:GametableExpandingDirection?) throws -> [CardViewModel.KeyValue]
}

protocol DealerViewModelDelegate : AnyObject {
    func gametableDeckIsEmpty()
}

enum DealerViewModelError : Error {
    case DeckIsEmpty
    case GametableIsNotDealing
    case CannotFindLocation
}

class DealerViewModel : DealerViewModelProtocol {
    
    init(deck:DeckModelProtocol
         , gametable: GametableViewModelProtocol)
    {
        self.deck = deck
        self.gametable = gametable
        
        self.gametable.adjustSizeToIncludeAllCardsLocations()
    }
    
    private var deck : DeckModelProtocol
    private(set) var gametable : GametableViewModelProtocol
    weak var delegate : DealerViewModelDelegate?
    
    private func getNewMatchingCardsModel() throws -> MatchingCardsModel  {
        defer {
            if deck.remainingMatchingCardsModels < 1 {
                delegate?.gametableDeckIsEmpty()
            }
        }
        guard let result = deck.getUniqueMatchingCardsModel() else {
            throw DealerViewModelError.DeckIsEmpty
        }
        return result
    }

    private func expandMatrix(expandingDirection request: GametableExpandingDirection?) {
        var newSize : Size2D
        // if size is zero or under (under shouldn't happen anyway), meaning empty gametable, this is a special case
        if gametable.size.rows < 1 && gametable.size.columns < 1 {
            newSize = Size2D(rows: 1, columns: 1)
        } else {
            // if size is not zero, neither rows or columns should be under 1
            newSize = Size2D(rows: max(1,gametable.size.rows) , columns: max(1, gametable.size.columns))
            
            let expandingDirection:GametableExpandingDirection
            if let request {
                expandingDirection = request
            } else {
                // then if request is nil, expanding gametable as a square
                if gametable.size.columns < gametable.size.rows {
                    expandingDirection = .column
                } else {
                    expandingDirection = .row
                }
            }
            switch (expandingDirection) {
            case .column: newSize.columns += 1
            case .row: newSize.rows += 1
            }
        }
        gametable.size = newSize
    }
    
    func addCardsInGametable(expandingDirection: GametableExpandingDirection?) throws  -> [CardViewModel.KeyValue] {
        // Getting new unique MatchingCardsModel
        let newMatchingCardsModel = try getNewMatchingCardsModel()
        // For coherence of object and the correct work of the following algorithm, adjust matrix size if necessary
        gametable.adjustSizeToIncludeAllCardsLocations()

        var result = [CardViewModel.KeyValue]()

        // Now creating cards for the new MatchingCardsModel
        for _ in 0..<gametable.cardsByMatch {
            // First thing to do is finding a free location in the matrix. Maybe we'll have to expand matrix.
            let newLocation : Location2D
            let usedLocations = Set(gametable.cards.values.map{$0.location})
            let emptyLocation : (Location2D) -> Bool = { usedLocations.contains($0) == false }
            
            if let firstEmptyLocationInMatrix = gametable.findFirstLocation(where: emptyLocation) {
                newLocation = firstEmptyLocationInMatrix
            } else {
                expandMatrix(expandingDirection: expandingDirection)
                
                if let firstEmptyLocationInMatrix = gametable.findFirstLocation(where: emptyLocation) {
                    newLocation = firstEmptyLocationInMatrix
                } else {
                    throw DealerViewModelError.CannotFindLocation
                }
            }
            
            // creating the new card and adding it in the gametable
            let newCard = CardViewModel(matchingCardsModel: newMatchingCardsModel
                                        , location: newLocation)
            let newKey = gametable.newKey
            gametable.cards[newKey] = newCard
            result.append((key:newKey, value:newCard))
        }
        return result
    }

}

#if DEBUG
extension DealerViewModel {
    internal var test_getNewMatchingCardsModel: () throws -> MatchingCardsModel { getNewMatchingCardsModel }
    internal var test_expandMatrix : (GametableExpandingDirection?) -> () { expandMatrix }
}
#endif
