//
//  MatchingCardsModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 05/01/2024.
//

import XCTest
@testable import FlipMe_OpenSource

final class MatchingCardsModelTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown()  {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_init_imageName() {
        let sut = MatchingCardsModel(image: .Single(imageName:  TestsValues.String))
        
        XCTAssertEqual(sut.image, .Single(imageName: TestsValues.String))
    }

    func test_TwoInit_IdentifierShouldBeUnique() {
        let sut1 = MatchingCardsModel(image: .Single(imageName: TestsValues.String))
        let sut2 = MatchingCardsModel(image: .Single(imageName:  TestsValues.String))
        
        XCTAssertNotEqual(sut1.id, sut2.id)
    }

    func test_TwoInit_InstanceShouldBeDifferent() {
        let sut1 = MatchingCardsModel(image: .Single(imageName: TestsValues.String))
        let sut2 = MatchingCardsModel(image: .Single(imageName: TestsValues.String))
        
        XCTAssertNotEqual(sut1,sut2)
    }
    
    func test_CopyValue_ShouldBeEqual() {
        let sut = MatchingCardsModel(image: .Single(imageName: TestsValues.String))
        let sutCopy = sut
        
        XCTAssertEqual(sut,sutCopy)
        
    }

}
