//
//  MockImagesLibraryPickerModel.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 08/02/2024.
//

import Foundation

@testable import Concentration_Storyboard

struct MockImagesLibraryPickerModelUnlimited: ImagesLibraryPickerModelProtocol {
    var library: ImagesLibraryModelProtocol = MockImagesLibraryModelEmpty()
    var delivered: Set<ImageName> = []
    
    func remainingCount(for: ImageCategory) -> Int {
        1
    }
    
    private(set) var popRandomCalls = 0
    mutating func popRandom(for: ImageCategory) -> ImageName? {
        popRandomCalls += 1
        return TestsValues.String
    }
    
    private(set) var resetCalls = 0
    mutating func reset(renewingImages: Bool) {
        resetCalls += 1
    }
}


struct MockImagesLibraryPickerModelEmpty: ImagesLibraryPickerModelProtocol {
    var library: ImagesLibraryModelProtocol = MockImagesLibraryModelEmpty()
    var delivered: Set<ImageName> = []
    
    func remainingCount(for: ImageCategory) -> Int {
        0
    }
    
    private(set) var popRandomCalls = 0
    mutating func popRandom(for: ImageCategory) -> ImageName? {
        popRandomCalls += 1
        return nil
    }
    
    private(set) var resetCalls = 0
    mutating func reset(renewingImages: Bool) {
        resetCalls += 1
    }
}

struct MockImagesLibraryPickerModelWith3Images: ImagesLibraryPickerModelProtocol {
    var library: ImagesLibraryModelProtocol = MockImagesLibraryModelEmpty()
    var delivered: Set<ImageName> = []
    
    func remainingCount(for: ImageCategory) -> Int {
        0
    }
    
    private(set) var popRandomCalls = 0
    mutating func popRandom(for: ImageCategory) -> ImageName? {
        popRandomCalls += 1
        return nil
    }
    
    private(set) var resetCalls = 0
    mutating func reset(renewingImages: Bool) {
        resetCalls += 1
    }
}
