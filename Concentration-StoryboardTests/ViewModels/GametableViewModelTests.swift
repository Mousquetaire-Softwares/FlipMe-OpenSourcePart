//
//  GametableViewModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 15/01/2024.
//

import XCTest
@testable import FlipMe_OpenSource


final class GametableViewModelTests: XCTestCase {
    fileprivate var matchingCardsModel1 : MatchingCardsModel!
    fileprivate var matchingCardsModel2 : MatchingCardsModel!
    fileprivate var matchingCardsModel3 : MatchingCardsModel!
    fileprivate var card1 : CardViewModel!
    fileprivate var card2 : CardViewModel!
    fileprivate var card3 : CardViewModel!
    fileprivate var sut : GametableViewModel!
    
    override func setUp() {
        super.setUp()
        matchingCardsModel1 = MatchingCardsModel(image: .Single(imageName: "test1"))
        matchingCardsModel2 = MatchingCardsModel(image: .Single(imageName: "test2"))
        matchingCardsModel3 = MatchingCardsModel(image: .Single(imageName: "test3"))
        card1 = CardViewModel(matchingCardsModel: matchingCardsModel1, location: Location2D(row: 0, column: 0))
        card2 = CardViewModel(matchingCardsModel: matchingCardsModel2, location: Location2D(row: 0, column: 0))
        card3 = CardViewModel(matchingCardsModel: matchingCardsModel3, location: Location2D(row: 0, column: 0))
        sut = GametableViewModel(cardsByMatch: 2)
        
    }
    
    override func tearDown()  {
        super.tearDown()
        matchingCardsModel1 = nil
        matchingCardsModel2 = nil
        matchingCardsModel3 = nil
        card1 = nil
        card2 = nil
        card3 = nil
        sut = nil
    }
    
    func test_init_InitialState() {
        XCTAssertTrue(sut.cards.isEmpty)
        XCTAssertTrue(sut.unmatchedAndFacedUpCardsKeys.isEmpty)
        XCTAssertEqual(sut.size, Size2D(rows: 0, columns: 0))
    }

    
    func test_shuffleCardsLocations_CardsLocationsShouldBeShuffled() {
        let sutBeforeShuffle = fillWithCards(gametable:sut, numberOfCards:20)
        var sutAfterShuffle = sutBeforeShuffle
        
        sutAfterShuffle.shuffleCardsLocations()
        
        XCTAssertEqual(sutBeforeShuffle.cards.keys
                       ,sutAfterShuffle.cards.keys)
        XCTAssertEqual(sutBeforeShuffle.cards.values.map{ $0.matchingId }
                       ,sutAfterShuffle.cards.values.map{ $0.matchingId })
        XCTAssertNotEqual(sutBeforeShuffle.cards.values.map{ $0.location }
                          ,sutAfterShuffle.cards.values.map{ $0.location }
                          ,"RANDOM TEST: Deck cards seems not to be shuffled")
    }
    
    


    func test_Subscript() {
        sut.cards = [2:card2,3:card3]
        let result1 = sut[1]
        let result3 = sut[3]
        
        XCTAssertNil(result1)
        XCTAssertEqual(result3?.key, 3)
        XCTAssertEqual(result3?.value, card3)
    }
    
    func test_newKey() {
        var sutCopy = sut
        sut.cards = [1:card1]
        sutCopy?.cards = [:]
        
        XCTAssertEqual(sut.newKey, 2)
        XCTAssertEqual(sutCopy?.newKey, 0)
    }

    func test_UnmatchedAndFacedUpCardsIndices_WithAllFaceDown_ShouldBeEmpty() {
        sut.cards = [11:card1,12:card1
                     ,21:card2,22:card2
                     ,31:card3,32:card3]

        let result = sut.unmatchedAndFacedUpCardsKeys

        XCTAssertTrue(result.isEmpty)
    }

    func test_UnmatchedAndFacedUpCardsIndices_With3CardsUp_ShouldBeOneAlone() {
        sut.cards = [11:card1,12:card1
                     ,21:card2,22:card2
                     ,31:card3,32:card3]
        sut.cards[11]?.isFaceUp = true
        sut.cards[21]?.isFaceUp = true
        sut.cards[22]?.isFaceUp = true
        sut.cards[21]?.isMatched = true
        sut.cards[22]?.isMatched = true
        
        let result = sut.unmatchedAndFacedUpCardsKeys

        let expected = Set([11])
        XCTAssertEqual(result,expected)
    }

    func test_CardsMatches_WithSameCardAndSameIndex_ShouldBeFalse() {
        let cardKeyValue1 : CardViewModel.KeyValue = (key:1,value:card1)
        
        let result = GametableViewModel.cardsMatches([cardKeyValue1,cardKeyValue1])
        
        XCTAssertFalse(result)
    }

    func test_CardsMatches_WithLessThanTwoCards_ShouldBeFalse() {
        let cardKeyValue1 : CardViewModel.KeyValue = (key:1,value:card1)
        
        let result0 = GametableViewModel.cardsMatches([])
        let result1 = GametableViewModel.cardsMatches([cardKeyValue1])
        
        XCTAssertFalse(result0)
        XCTAssertFalse(result1)
    }

    func test_CardsMatches_WithSameCardAndDifferentIndices_ShouldBeTrue() {
        let cardKeyValue1 : CardViewModel.KeyValue = (key:1,value:card1)
        let cardKeyValue2 : CardViewModel.KeyValue = (key:2,value:card1)
        let cardKeyValue3 : CardViewModel.KeyValue = (key:3,value:card1)
        
        let result1 = GametableViewModel.cardsMatches([cardKeyValue1,cardKeyValue2])
        let result2 = GametableViewModel.cardsMatches([cardKeyValue1,cardKeyValue2,cardKeyValue3])
        
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
    }

    func test_CardsMatches_WithDifferentCards_ShouldBeFalse() {
        let cardKeyValue1Key1 : CardViewModel.KeyValue = (key:1,value:card1)
        let cardKeyValue2Key1 : CardViewModel.KeyValue = (key:1,value:card2)
        let cardKeyValue2Key2 : CardViewModel.KeyValue = (key:2,value:card2)
        
        let result1 = GametableViewModel.cardsMatches([cardKeyValue1Key1,cardKeyValue2Key1])
        let result2 = GametableViewModel.cardsMatches([cardKeyValue1Key1,cardKeyValue2Key2])
        
        XCTAssertFalse(result1)
        XCTAssertFalse(result2)
    }
    
    func test_AdjustSizeToIncludeAllCardsLocations_WithGreaterLocationsThanSize_ShouldRaise() {
        sut.cards = [11:card1,12:card1
                     ,21:card2,22:card2]
        sut.cards[12]?.location = Location2D(row: 2-1, column: 4-1)
        var sut2 = sut
        var sut3 = sut
        
        sut.size = Size2D(rows:2,columns:3)
        sut2?.size = Size2D(rows:0,columns:5)
        sut3?.size = Size2D(rows:1,columns:1)
        sut.adjustSizeToIncludeAllCardsLocations()
        sut2?.adjustSizeToIncludeAllCardsLocations()
        sut3?.adjustSizeToIncludeAllCardsLocations()
        
        XCTAssertEqual(sut.size, Size2D(rows:2,columns:4))
        XCTAssertEqual(sut2?.size, Size2D(rows:2,columns:5))
        XCTAssertEqual(sut3?.size, Size2D(rows:2,columns:4))
    }
    
    func test_AdjustSizeToIncludeAllCardsLocations_WithCardsEmpty_ShouldNotChange() {
        sut.size = Size2D(rows:0,columns:0)
        
        sut.adjustSizeToIncludeAllCardsLocations()
        
        XCTAssertEqual(sut.size, Size2D(rows:0,columns:0))
    }
    
    func test_FindFirstLocation_WithSizeZero_ShouldBeNil() {
        var sut2 = sut
        var sut3 = sut
        
        sut.size = Size2D(rows:0,columns:0)
        sut2?.size = Size2D(rows:1,columns:0)
        sut3?.size = Size2D(rows:0,columns:1)
        
        XCTAssertNil(sut.findFirstLocation(where: { _ in true }))
        XCTAssertNil(sut2?.findFirstLocation(where: { _ in true }))
        XCTAssertNil(sut3?.findFirstLocation(where: { _ in true }))
    }
     
    
    func test_FindFirstLocation_ShouldFollowRouteOrder() {
        /// Expected order from function in a 3x3 matrix :
        /// 0 1 4
        /// 2 3 5
        /// 6 7 8
        let locationsExpectedOrder = [
            Location2D(row: 0, column:0) : 0
            ,Location2D(row:0, column:1) : 1
            ,Location2D(row:1, column:0) : 2
            ,Location2D(row:1, column:1) : 3
            ,Location2D(row:0, column:2) : 4
            ,Location2D(row:1, column:2) : 5
            ,Location2D(row:2, column:0) : 6
            ,Location2D(row:2, column:1) : 7
            ,Location2D(row:2, column:2) : 8
        ]
        // Filling cards of sut with those locations in reverse order
        var allocatedLocations = locationsExpectedOrder.keys.reversed()[...]
        for key in 0...8 {
            var card = card1!
            let location = allocatedLocations.popFirst()!
            card.location = location
            sut.cards[key] = card
        }
        sut.size = Size2D(rows: 3, columns: 3)
        
        var foundLocations = [Location2D]()
        let predicate : (Location2D)->Bool = { !foundLocations.contains($0) }
        
        for nextLocationExpectedPosition in 0...8 {
            let foundLocation = sut.findFirstLocation(where: predicate)!
            foundLocations.append(foundLocation)
            
            XCTAssertEqual(locationsExpectedOrder[foundLocation], nextLocationExpectedPosition)
        }
        XCTAssertNil(sut.findFirstLocation(where: predicate))
    }
    
    func test_shuffleCardsLocations_ShouldChangeOrderOfLocations() throws {
        let sutBeforeShuffle = fillWithCards(gametable:sut, numberOfCards:20)
        var sutAfterShuffle = sutBeforeShuffle
        
        sutAfterShuffle.shuffleCardsLocations()
        
        XCTAssertEqual(sutBeforeShuffle.cards.keys
                       ,sutAfterShuffle.cards.keys)
        XCTAssertEqual(sutBeforeShuffle.cards.values.map{ $0.matchingId }
                       ,sutAfterShuffle.cards.values.map{ $0.matchingId })
        XCTAssertNotEqual(sutBeforeShuffle.cards.values.map{ $0.location }
                          ,sutAfterShuffle.cards.values.map{ $0.location }
                          ,"Deck cards seems not to be shuffled")
    }
    
    private func fillWithCards(gametable:GametableViewModel, numberOfCards:Int) -> GametableViewModel {
        var result = gametable
        let templateCards = [card1,card2,card3]
        for i in 0..<numberOfCards {
            var card = templateCards[i%3]!
            card.location = Location2D(row: i/10, column: i%10)
            result.cards[i] = card
        }
        return result
    }
}
