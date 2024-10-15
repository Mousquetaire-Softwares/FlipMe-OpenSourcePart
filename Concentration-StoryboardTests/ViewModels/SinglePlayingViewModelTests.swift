//
//  SinglePlayingViewModel.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 18/01/2024.
//

import XCTest
@testable import Concentration_Storyboard

// Mock classes for testing

//struct GametableViewModelMock: GametableViewModelProtocol {
//    var size: Concentration_Storyboard.Size2D
//    var cards: [CardViewModel.Key: CardViewModel] = [:]
//    var state: GametableState = .Dealing
//}

final class SinglePlayingViewModelTests: XCTestCase {
    var mockDeck: MockDeckModel!
    var mockDelegate: MockPlayingEngineViewModelDelegate!
    var mockScoreEngine: MockScoreEngineViewModel!
    var initialMockGametable: MockGametableViewModel!
    var sut: SinglePlayingViewModel!
    let cardPair1Key1 = 11
    let cardPair1Key2 = 12
    let cardPair2Key1 = 21
    let cardPair2Key2 = 22
    
    override func setUp() {
        super.setUp()
        mockDeck = MockDeckModel()
        mockDelegate = MockPlayingEngineViewModelDelegate()
        mockScoreEngine = MockScoreEngineViewModel()
        let matchingCardsModel1 = MatchingCardsModel(image: .Single(imageName: TestsValues.String))
        let matchingCardsModel2 = MatchingCardsModel(image: .Single(imageName: TestsValues.String))
        let matchingCardsModel3 = MatchingCardsModel(image: .Single(imageName: TestsValues.String))
        
        let cards = [
            cardPair1Key1:CardViewModel(matchingCardsModel: matchingCardsModel1, location: Location2D(row: 1, column: 1))
            ,cardPair1Key2:CardViewModel(matchingCardsModel: matchingCardsModel1, location: Location2D(row: 1, column: 2))
            ,cardPair2Key1:CardViewModel(matchingCardsModel: matchingCardsModel2, location: Location2D(row: 2, column: 1))
            ,cardPair2Key2:CardViewModel(matchingCardsModel: matchingCardsModel2, location: Location2D(row: 2, column: 2))
            ,31:CardViewModel(matchingCardsModel: matchingCardsModel3, location: Location2D(row: 3, column: 1))
            ,32:CardViewModel(matchingCardsModel: matchingCardsModel3, location: Location2D(row: 3, column: 2))
        ]
        initialMockGametable = MockGametableViewModel(cards: cards
                                                      , cardsByMatch: 2
                                                      , size: Size2D(rows: 0, columns: 0))
        initialMockGametable.adjustSizeToIncludeAllCardsLocations()
        
        sut = SinglePlayingViewModel(gametable: initialMockGametable
                                     , scoreEngine: mockScoreEngine)
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        super.tearDown()
        mockDeck = nil
        mockDelegate = nil
        mockScoreEngine = nil
        initialMockGametable = nil
        sut = nil
    }
    
    func test_init() {
        XCTAssertEqual(sut.gametable.cards, initialMockGametable.cards)
    }
    
    func test_faceUp_OneCall() throws {
        try sut.faceUp(cardPair1Key1)
        
        XCTAssertTrue(sut.gametable.cards[cardPair1Key1]?.isFaceUp ?? false)
        XCTAssertEqual(mockDelegate.gametableCardsUpdatedCalls.count, 1)
        XCTAssertEqual(mockDelegate.gametableCardsUpdatedCalls.first!.count, 1)
        XCTAssertEqual(mockDelegate.gametableCardsUpdatedCalls.first!.first, cardPair1Key1)
        XCTAssertEqual(mockScoreEngine.cardIsFacingUpCalls.count, 1)
    }
    func test_faceUp_TwoCallsMatchingCards() throws {
        try sut.faceUp(cardPair1Key1)
        try sut.faceUp(cardPair1Key2)
        
        XCTAssertTrue(sut.gametable.cards[cardPair1Key1]?.isFaceUp ?? false)
        XCTAssertTrue(sut.gametable.cards[cardPair1Key2]?.isFaceUp ?? false)
        XCTAssertTrue(sut.gametable.cards[cardPair1Key1]?.isMatched ?? false)
        XCTAssertTrue(sut.gametable.cards[cardPair1Key2]?.isMatched ?? false)
        XCTAssertEqual(mockDelegate.gametableCardsUpdatedCalls.count, 3)
        XCTAssertEqual(mockDelegate.gametableCardsUpdatedCalls.last!.count, 2)
        XCTAssertEqual(mockDelegate.gametableCardsUpdatedCalls.last!, [cardPair1Key1,cardPair1Key2])
        XCTAssertEqual(mockDelegate.gametableRoundIsOverCalls.count, 1)
        XCTAssertEqual(mockScoreEngine.cardIsFacingUpCalls.count, 2)
        XCTAssertEqual(mockScoreEngine.roundIsOverCalls.count, 1)
        XCTAssertEqual(mockScoreEngine.roundIsOverCalls.first!.matchesFound, 1)
        XCTAssertEqual(mockScoreEngine.roundIsOverCalls.first!.roundPlayedCards, [cardPair1Key1,cardPair1Key2])
        
    }
}
