//
//  ParticlesLibraryViewModelTests.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 29/03/2024.
//

import XCTest
@testable import Concentration_Storyboard

final class ParticlesLibraryViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_EnumDataImagesNames_ShouldAllExistsInAsset() {
        let allImageNames : [[[ImageName]]] = [
            ParticlesLibraryViewModel.HappyFaces.InternalDataImagesNamesByColor.values.map{ $0 }
            ,ParticlesLibraryViewModel.Stars.InternalDataImagesNamesByColor.values.map{ $0 }
            ,ParticlesLibraryViewModel.BadFaces.InternalDataImagesNamesByColor.values.map{ $0 }
            ,ParticlesLibraryViewModel.Exclamations.InternalDataImagesNamesByColor.values.map{ $0 }
            ,[ParticlesLibraryViewModel.Rainbows.InternalDataImagesNames]
        ]
        for imageName in allImageNames.flatMap({ $0.flatMap{ $0 } }) {
            let image = UIImage(named: imageName)
            XCTAssertNotNil(image, "Missing image named : \(imageName)")
        }
    }

    func test_EnumUIImages_ShouldAllHaveAtLeastOneImage() {
        for color in ParticlesLibraryViewModel.HappyFaces.allCases {
            XCTAssertFalse(color.UIImages.isEmpty)
        }
        for color in ParticlesLibraryViewModel.Stars.allCases {
            XCTAssertFalse(color.UIImages.isEmpty)
        }
        for color in ParticlesLibraryViewModel.BadFaces.allCases {
            XCTAssertFalse(color.UIImages.isEmpty)
        }
        for color in ParticlesLibraryViewModel.Exclamations.allCases {
            XCTAssertFalse(color.UIImages.isEmpty)
        }
        XCTAssertFalse(ParticlesLibraryViewModel.Rainbows.UIImages.isEmpty)
    }

}
