//
//  ScoreRankViewControllerTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 18/04/2024.
//

import XCTest
@testable import FlipMe_OpenSource


final class ScoreRankViewControllerTests: XCTestCase {
    
    override func setUp() {
    }
    
    override func tearDown()  {
    }
    
    
//    func test_loadingFromXib() {
//        let sut = ScoreRankViewController()
//        sut.loadViewIfNeeded()
//        XCTAssertNotNil(sut.perfectRank)
//    }
    
    func test_UIParameterImagesForRanks_ShouldAllExistsInAsset() {
        ScoreRankViewController.UIParameter.ImagesForRanks.forEach{
            [$0.bad, $0.good, $0.perfect].forEach{
                let image = UIImage(named: $0)
                XCTAssertNotNil(image, "Missing image named : \($0)")
            }
        }
    }

}
