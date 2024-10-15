//
//  MockImagesLibraryModel.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 07/02/2024.
//

import Foundation
import CoreGraphics
@testable import FlipMe_OpenSource

    
// Mock implementation of ImagesLibraryModelProtocol for testing
class MockImagesLibraryModel: ImagesLibraryModelProtocol {
    
    var filterCalls = [(imageSet: ImageSet, for: ImageCategory)]()
    func filter(_ imageSet: ImageSet, for category: ImageCategory) -> ImageSet {
        filterCalls.append((imageSet:imageSet,for:category))
        return imageSet
    }
    
    var lockedSet : ImageSet {
        []
    }
    
    func lockedImageAvailable() -> Bool {
        true
    }
    
    private(set) var loadDatabaseValuesCalls = 0
    func loadDatabaseValues() {
        loadDatabaseValuesCalls += 1
    }
    
    private(set) var saveDatabaseValuesCalls = 0
    func saveDatabaseValues() {
        saveDatabaseValuesCalls += 1
    }
    
    var unlockNewImageCalls = [(for: ImageCategory?, and: ImageCategory?)]()
    func unlockNewImage(for category1: ImageCategory?, and category2: ImageCategory?) -> ImageName? {
        unlockNewImageCalls.append((for:category1,and:category2))
        return nil
    }
    
    
    var availableSet : ImageSet {
        data[.AnyImage] ?? []
    }
    
    var data = Dictionary<ImageCategory,Set<ImageName>>()
    
}


class MockImagesLibraryModelEmpty: MockImagesLibraryModel {
    override var availableSet : ImageSet {
        []
    }
}

class MockImagesLibraryModelWith3Images: MockImagesLibraryModel {
    override var availableSet : ImageSet {
        [TestsValues.String1,TestsValues.String2,TestsValues.String3]
    }
}
