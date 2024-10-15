//
//  DealerViewModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 16/01/2024.
//

import XCTest
@testable import Concentration_Storyboard

// Mock classes for testing

class MockDealerViewModelDelegate : DealerViewModelDelegate {
    var gametableDeckIsEmptyCalls = 0
    func gametableDeckIsEmpty() {
        gametableDeckIsEmptyCalls += 1
    }
}
//struct GametableViewModelMock: GametableViewModelProtocol {
//    var size: Concentration_Storyboard.Size2D
//    var cards: [CardViewModel.Key: CardViewModel] = [:]
//    var state: GametableState = .Dealing
//}

final class DealerViewModelTests: XCTestCase {
    var mockDeck: MockDeckModel!
    var mockDelegate: MockDealerViewModelDelegate!
//    var sut: DealerViewModel!
    
    override func setUp() {
        super.setUp()
        mockDeck = MockDeckModel()
        mockDelegate = MockDealerViewModelDelegate()
//        let gametable = GametableViewModel(cardsByMatch: 2)
//        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
    }
    
    override func tearDown() {
        super.tearDown()
        mockDeck = nil
        mockDelegate = nil
//        let sut = nil
    }
    
    func test_getNewMatchingCardsModel_ShouldCreateCardFromDeck() {
        mockDeck.remainingMatchingCardsModels = 1
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        let result = try? sut.test_getNewMatchingCardsModel()
        
        XCTAssertNotNil(result)
    }
    
    func test_getNewMatchingCardsModel_WithEmptyDeck_ShouldRaiseError() {
        mockDeck.remainingMatchingCardsModels = 0
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        var errorRaised:Error?
        do {
            _ = try sut.test_getNewMatchingCardsModel()
        } catch {
            errorRaised = error
        }
        
        XCTAssertEqual(errorRaised as? DealerViewModelError, DealerViewModelError.DeckIsEmpty)
    }
    
    func test_getNewMatchingCardsModel_WithEmptyDeck_ShouldCallDelegate() {
        mockDeck.remainingMatchingCardsModels = 0
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        sut.delegate = mockDelegate
        _ = try? sut.test_getNewMatchingCardsModel()

        XCTAssertEqual(mockDelegate.gametableDeckIsEmptyCalls, 1)
    }
    
    func test_getNewMatchingCardsModel_WithOneCardInDeck_ShouldCallDelegate() {
        mockDeck.remainingMatchingCardsModels = 1
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        sut.delegate = mockDelegate
        _ = try? sut.test_getNewMatchingCardsModel()
        
        XCTAssertEqual(mockDelegate.gametableDeckIsEmptyCalls, 1)
    }
    func test_getNewMatchingCardsModel_WithTwoCardInDeck_ShouldNotCallDelegate() {
        mockDeck.remainingMatchingCardsModels = 2
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        _ = try? sut.test_getNewMatchingCardsModel()
        
        XCTAssertEqual(mockDelegate.gametableDeckIsEmptyCalls, 0)
    }
    
    func test_expandMatrix_WithSize0x0_ShouldBe1x1() {
        var gametable = GametableViewModel(cardsByMatch: 2)
        gametable.size = Size2D(rows: 0, columns: 0)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        let direction : GametableExpandingDirection? = .row
        
        sut.test_expandMatrix(direction)
        
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 1, columns: 1))
    }
    func test_expandMatrix_WithSize0x1AndExpandRow_ShouldBe2x1() {
        var gametable = GametableViewModel(cardsByMatch: 2)
        gametable.size = Size2D(rows: 0, columns: 1)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        let direction : GametableExpandingDirection? = .row
        
        sut.test_expandMatrix(direction)
        
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 2, columns: 1))
    }
    func test_expandMatrix_WithSize2x3AndExpandColumn_ShouldBe2x4() {
        var gametable = GametableViewModel(cardsByMatch: 2)
        gametable.size = Size2D(rows: 2, columns: 3)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        let direction : GametableExpandingDirection? = .column
        
        sut.test_expandMatrix(direction)
        
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 2, columns: 4))
    }
    func test_expandMatrix_WithSize1x1AndExpandRow_ShouldBe2x1() {
        var gametable = GametableViewModel(cardsByMatch: 2)
        gametable.size = Size2D(rows: 1, columns: 1)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        let direction : GametableExpandingDirection? = .row
        
        sut.test_expandMatrix(direction)
        
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 2, columns: 1))
    }
    func test_expandMatrix_WithSize3x1AndExpandNil_ShouldBe3x2() {
        var gametable = GametableViewModel(cardsByMatch: 2)
        gametable.size = Size2D(rows: 3, columns: 1)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        let direction : GametableExpandingDirection? = nil
        
        sut.test_expandMatrix(direction)
        
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 3, columns: 2))
    }
    func test_expandMatrix_WithSize1x3AndExpandNil_ShouldBe2x3() {
        var gametable = GametableViewModel(cardsByMatch: 2)
        gametable.size = Size2D(rows: 1, columns: 3)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        let direction : GametableExpandingDirection? = nil
        
        sut.test_expandMatrix(direction)
        
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 2, columns: 3))
    }
//    func test_expandMatrix_WithSize<#X#>x<#X#>AndExpand<#RowColumn#>_ShouldBe<#X#>x<#X#>() {
//        var gametable = GametableViewModel(cardsByMatch: 2)
//        gametable.size = Size2D(rows: <#T##Int#>, columns: <#T##Int#>)
//        let sut = DealerViewModel(deck: deckMock, gametable: gametable, delegate: delegate)
//        let direction : GametableExpandingDirection? = <#value#>
//        
//        sut.test_expandMatrix(direction)
//        
//        XCTAssertEqual(sut.gametable.size, Size2D(rows: <#T##Int#>, columns: <#T##Int#>))
//    }

    
    func test_addCardsInGametable_WithEmptyDeck_ShouldRaiseError() {
        mockDeck.remainingMatchingCardsModels = 0
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        var errorRaised:Error?
        do {
            _ = try sut.addCardsInGametable(expandingDirection: nil)
        } catch {
            errorRaised = error
        }
        
        XCTAssertEqual(errorRaised as? DealerViewModelError, DealerViewModelError.DeckIsEmpty)
    }
    
    func test_addCardsInGametable_With2CardsByMatch_ShouldAdd2MatchingCards() {
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        let result = try? sut.addCardsInGametable(expandingDirection: .column)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
        XCTAssertEqual(result![0].value.matchingId, result![1].value.matchingId)
        XCTAssertEqual(result![0].value.location, Location2D(row: 0, column: 0))
        XCTAssertEqual(result![1].value.location, Location2D(row: 0, column: 1))
        XCTAssertNotEqual(result![0].key, result![1].key)
        XCTAssertEqual(sut.gametable.cards.count, 2)
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 1, columns: 2))
    }
    func test_addCardsInGametable_With3CardsByMatch_ShouldAdd3MatchingCards() {
        let gametable = GametableViewModel(cardsByMatch: 3)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        let result = try? sut.addCardsInGametable(expandingDirection: .row)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 3)
        XCTAssertEqual(result![0].value.matchingId, result![1].value.matchingId)
        XCTAssertEqual(result![0].value.matchingId, result![2].value.matchingId)
        XCTAssertEqual(result![0].value.location, Location2D(row: 0, column: 0))
        XCTAssertEqual(result![1].value.location, Location2D(row: 1, column: 0))
        XCTAssertEqual(result![2].value.location, Location2D(row: 2, column: 0))
        XCTAssertNotEqual(result![0].key, result![1].key)
        XCTAssertNotEqual(result![0].key, result![2].key)
        XCTAssertNotEqual(result![1].key, result![2].key)
        XCTAssertEqual(sut.gametable.cards.count, 3)
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 3, columns: 1))
    }
    func test_addCardsInGametable_TwoTimesAndDirectionNil_ShouldPutCardsInSquare() {
        let gametable = GametableViewModel(cardsByMatch: 2)
        let sut = DealerViewModel(deck: mockDeck, gametable: gametable)
        
        var result = try! sut.addCardsInGametable(expandingDirection: nil)
        result.append(contentsOf: try! sut.addCardsInGametable(expandingDirection: nil))
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].value.location, Location2D(row: 0, column: 0))
        XCTAssertEqual(result[1].value.location, Location2D(row: 1, column: 0))
        XCTAssertEqual(result[2].value.location, Location2D(row: 0, column: 1))
        XCTAssertEqual(result[3].value.location, Location2D(row: 1, column: 1))
        XCTAssertEqual(sut.gametable.cards.count, 4)
        XCTAssertEqual(sut.gametable.size, Size2D(rows: 2, columns: 2))
    }
}


