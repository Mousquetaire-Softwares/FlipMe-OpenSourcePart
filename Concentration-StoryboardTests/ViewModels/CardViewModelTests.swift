//
//  CardViewModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 15/01/2024.
//

import XCTest
@testable import FlipMe_OpenSource

final class CardViewModelTests: XCTestCase {
    fileprivate var matchingCardsModelMock1 : MatchingCardsModel!
    fileprivate var matchingCardsModelMock2 : MatchingCardsModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        matchingCardsModelMock1 = MatchingCardsModel(image: .Single(imageName: "Test1"))
        matchingCardsModelMock2 = MatchingCardsModel(image: .Single(imageName: "Test2"))
    }

    override func tearDownWithError() throws {
        matchingCardsModelMock1 = nil
        matchingCardsModelMock2 = nil
    }
    
    func test_Init_InitialValues() {
        let location = Location2D(row: 3, column: 4)
        let sut = CardViewModel(matchingCardsModel: matchingCardsModelMock2, location: location)
        
        
        XCTAssertEqual(sut.image, matchingCardsModelMock2.image)
        XCTAssertEqual(sut.matchingId, matchingCardsModelMock2.id)
        XCTAssertEqual(sut.isFaceUp, false)
        XCTAssertEqual(sut.isMatched, false)
        XCTAssertEqual(sut.isOutOfGame, false)
        XCTAssertEqual(sut.location, location)
    }

    func test_ShouldBeValueTyped() {
        let location = Location2D(row: 1, column: 2)
        let sut1 = CardViewModel(matchingCardsModel: matchingCardsModelMock1, location: location)
        
        var sut2 = sut1
        sut2.isFaceUp = !sut1.isFaceUp
        
        XCTAssertNotEqual(sut1, sut2)
    }


    func test_TwoInstancesSameValues_ShouldBeEqual() {
        let location = Location2D(row: 1, column: 2)
        var sut1 = CardViewModel(matchingCardsModel: matchingCardsModelMock1, location: location)
        var sut2 = CardViewModel(matchingCardsModel: matchingCardsModelMock1, location: location)
        
        sut1.isFaceUp = true
        sut2.isFaceUp = true
        
        XCTAssertEqual(sut1, sut2)
    }


}
