//
//  LevelViewControllerTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 02/01/2024.
//
//
import XCTest
@testable import Concentration_Storyboard

final class LevelViewControllerTests: XCTestCase {
    fileprivate var sut : LevelViewController!
    var mockLevelViewControllerDelegate: MockLevelViewControllerDelegate!
    
    override func setUp()  {
        sut = UIStoryboard(name: LevelViewController.UIDesign.StoryboardName, bundle: nil)
            .instantiateViewController(identifier: LevelViewController.UIDesign.StoryboardId
                                       ,creator: {
                coder in
//                let deck = SingleImageDeckModel(imagesPicker: MockImagesLibraryPickerModelEmpty())
//                let cardsToDeal = 10
                
                let level = MockLevelViewModel(key: LevelKey(stage:0, level:0)
                                               , gameProcess: .NotInitialized
                                               , cardsByMatch: 2
                                               , cardsToDeal: 10
                                               , unlocked: true)
                return LevelViewController(level: level
                                           ,delegate: self.mockLevelViewControllerDelegate
                                           ,coder: coder)
            }
            )
    }

    override func tearDown() {
        sut = nil
        mockLevelViewControllerDelegate = nil
    }

    
//    func test_loading_withoutGameMode_ShouldLeaveController() {
//        sut.loadViewIfNeeded()
////        To be continued ...
//    }

}
