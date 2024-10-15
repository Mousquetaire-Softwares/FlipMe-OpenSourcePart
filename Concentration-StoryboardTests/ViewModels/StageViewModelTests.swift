//
//  StageViewModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 26/02/2024.
//

import XCTest
@testable import Concentration_Storyboard

struct MockStageModel : StageModelProtocol {
    
    var key: StageKey
    
    var id: InvariantId
    
    var unlocked: Bool
    
    var levels: [LevelModelProtocol]
    
    var cardsByMatch: Int?
    
    var cardsToDeal: Int?
    
    var userCanDealCards: Bool?
    
    var cardsType: CardType?
    
    var gamePlayingMode: GamePlayingMode?
    
    
}

final class StageViewModelTests: XCTestCase {
    private var mockStageModel : MockStageModel!
    private var mockImagesPicker : MockImagesLibraryPickerModelUnlimited!
    
    override func setUp() {
        mockStageModel = MockStageModel(key: TestsValues.Int
                                        , id: TestsValues.String
                                        , unlocked: false
                                        , levels: [])
        mockImagesPicker = MockImagesLibraryPickerModelUnlimited()
    }

    override func tearDown() {
        mockStageModel = nil
        mockImagesPicker = nil
    }

    func test_init() {
        mockStageModel.gamePlayingMode = .SinglePlayer
        let sut = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        
        XCTAssertEqual(sut.cardsByMatch, mockStageModel.cardsByMatch)
        XCTAssertEqual(sut.key, mockStageModel.key)
        XCTAssertEqual(sut.playersCount, 1)
    }

    func test_cardsExample_WithCardsTypeSingleImage() {
        mockStageModel.gamePlayingMode = .SinglePlayer
        mockStageModel.cardsType = .SingleImage
        mockStageModel.cardsByMatch = 2
        var sut1 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut1CardsExamples = sut1.generateCardsExamples()
        mockStageModel.cardsByMatch = 3
        var sut2 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut2CardsExamples = sut2.generateCardsExamples()
        
        XCTAssertEqual(sut1CardsExamples.count, 1)
        XCTAssertEqual(sut1CardsExamples.first?.count, 2)
        XCTAssertEqual(sut2CardsExamples.count, 1)
        XCTAssertEqual(sut2CardsExamples.first?.count, 3)
    }
    
    func test_cardsExample_WithCardsTypeSingleImageMultiColors() {
        mockStageModel.gamePlayingMode = .SinglePlayer
        mockStageModel.cardsType = .SingleImageMultiColors(colorsCount: 3)
        mockStageModel.cardsByMatch = 2
        var sut1 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut1CardsExamples = sut1.generateCardsExamples()
        mockStageModel.cardsByMatch = 3
        var sut2 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut2CardsExamples = sut2.generateCardsExamples()
        
        XCTAssertEqual(sut1CardsExamples.count, 3)
        XCTAssertEqual(sut1CardsExamples.first?.count, 2)
        XCTAssertEqual(sut2CardsExamples.count, 3)
        XCTAssertEqual(sut2CardsExamples.first?.count, 3)
    }
    
    func test_cardsExample_WithCardsTypeDualImage() {
        mockStageModel.gamePlayingMode = .SinglePlayer
        mockStageModel.cardsType = .DualImage
        mockStageModel.cardsByMatch = 2
        var sut1 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut1CardsExamples = sut1.generateCardsExamples()
        mockStageModel.cardsByMatch = 3
        var sut2 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut2CardsExamples = sut2.generateCardsExamples()
        
        XCTAssertEqual(sut1CardsExamples.count, 1)
        XCTAssertEqual(sut1CardsExamples.first?.count, 2)
        XCTAssertEqual(sut2CardsExamples.count, 1)
        XCTAssertEqual(sut2CardsExamples.first?.count, 3)
    }
    
    func test_cardsExample_WithCardsTypeDualImageMultiOrder() {
        mockStageModel.gamePlayingMode = .SinglePlayer
        mockStageModel.cardsType = .DualImageMultiOrder
        mockStageModel.cardsByMatch = 2
        var sut1 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut1CardsExamples = sut1.generateCardsExamples()
        mockStageModel.cardsByMatch = 3
        var sut2 = StageViewModel(model: mockStageModel, usingForCardsExamples: mockImagesPicker)
        let sut2CardsExamples = sut2.generateCardsExamples()
        
        XCTAssertEqual(sut1CardsExamples.count, 2)
        XCTAssertEqual(sut1CardsExamples.first?.count, 2)
        XCTAssertEqual(sut2CardsExamples.count, 2)
        XCTAssertEqual(sut2CardsExamples.first?.count, 3)
    }
}
