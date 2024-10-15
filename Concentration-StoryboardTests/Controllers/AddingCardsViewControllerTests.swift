//
//  CardsDealerViewControllerTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 11/12/2023.
//

import XCTest
@testable import Concentration_Storyboard



fileprivate class MockDelegate : CardsDealerViewControllerDelegate {
    var addMatchingCardsCalls = 0
    func addCards() {
        addMatchingCardsCalls += 1
    }
}
    

final class CardsDealerViewControllerTests: XCTestCase {
            
    override func setUp() {
    }
    
    override func tearDown()  {
    }


    func test_loadingFromXib() {
        let sut = CardsDealerViewController()
        sut.loadViewIfNeeded()
        XCTAssertNotNil(sut.squaredView)
    }
    
    func test_loading_SquaredViewNumberOfSubviews_ShouldBe10() {
        let sut = CardsDealerViewController()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.squaredView.subviews.count, 10)
    }
    
//    func test_squaredView_TapGesture_ShouldCallDelegate() {
//        let sut = CardsDealerViewController(self.mockCardsProvider)
//        sut.loadViewIfNeeded()
//        let delegate = MockDelegate()
//        sut.delegate = delegate
//    }

}
