//
//  GametableViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation

enum GametableExpandingDirection { case row, column }


protocol GametableViewModelProtocol {
    
    var cards : [CardViewModel.Key:CardViewModel] { get set }
    var cardsByMatch : Int { get }
    var size : Size2D { get set }
    subscript(key:CardViewModel.Key) -> CardViewModel.KeyValue? { get }
    var newKey : CardViewModel.Key { get }
    var unmatchedCardsKeys: Set<CardViewModel.Key> { get }
    var unmatchedAndFacedUpCardsKeys : Set<CardViewModel.Key> { get }
    
    mutating func findFirstLocation(where: (Location2D)->Bool) -> Location2D?
    mutating func shuffleCardsLocations()
    
    static func cardsMatches(_ cards:[CardViewModel.KeyValue]) -> Bool
}

extension GametableViewModelProtocol {
    subscript(key:CardViewModel.Key) -> CardViewModel.KeyValue? {
        get {
            if let value = cards[key] {
                return (key:key,value:value)
            } else {
                return nil
            }
        }
    }
    
    var newKey : CardViewModel.Key {
        return (cards.keys.max() ?? -1) + 1
    }
    
    var unmatchedCardsKeys: Set<CardViewModel.Key> {
        return Set(cards.keys.filter{ cards[$0]?.isMatched == false })
    }

     var unmatchedAndFacedUpCardsKeys: Set<CardViewModel.Key> {
        return unmatchedCardsKeys.filter{ cards[$0]?.isFaceUp == true }
    }

    
    mutating func adjustSizeToIncludeAllCardsLocations() {
        if cards.count == 0 {
            return
        }
        let newSize = Size2D(
            rows: max(size.rows, cards.values.map{ $0.location.row }.max()!+1)
            ,columns: max(size.columns, cards.values.map{ $0.location.column }.max()!+1)
        )
        if size != newSize {
            size = newSize
        }
    }
    
    /// Finds in matrix of locations the first location to satify the given predicate, starting from the origin location (0,0) and searching by following a squared shape expanding 1x1, 2x2, 3x3, ...
    /// Column are read first then the row.
    /// Travelling order expected :
    /// 0 1 4
    /// 2 3 5
    /// 6 7 8
    public mutating func findFirstLocation(where predicate: (Location2D)->Bool) -> Location2D? {
        for index in 0..<max(size.rows,size.columns) {
            let targetColumn = index
            let targetRow = index
            if targetColumn < size.columns {
                let column = targetColumn
                var row = 0
                while row <= min(targetRow-1, size.rows-1) {
                    let location = Location2D(row: row, column: column)
                    if predicate(location) {
                        return location
                    }
                    row += 1
                }
            }
            if targetRow < size.rows {
                let row = targetRow
                var column = 0
                while column <= min(targetColumn, size.columns-1) {
                    let location = Location2D(row: row, column: column)
                    if predicate(location) {
                        return location
                    }
                    column += 1
                }
            }
        }
        return nil
    }
    
    static func cardsMatches(_ cards:[CardViewModel.KeyValue]) -> Bool {
        let keys = Set<CardViewModel.Key>(cards.map{ $0.key })
        let matchingIds = Set<CardViewModel.MatchingId>(cards.map{ $0.value.matchingId })
        
        return cards.count >= 2 && keys.count == cards.count && matchingIds.count == 1
    }
}


struct GametableViewModel : GametableViewModelProtocol {
    init(cardsByMatch:Int = 2) {
        self.cardsByMatch = cardsByMatch
    }
    let cardsByMatch : Int
    var cards : [CardViewModel.Key:CardViewModel] = [:]
    var size = Size2D(rows: 0, columns: 0)

    
    public mutating func shuffleCardsLocations() {
        var shuffledLocations = cards.values.map{ $0.location }.shuffled()
        var newCards = cards
        newCards.keys.forEach{ newCards[$0]?.location = shuffledLocations.popLast()! }
        cards = newCards
    }
    

}
