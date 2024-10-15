//
//  MockImagesLibraryDatabase.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 22/04/2024.
//

import Foundation
@testable import Concentration_Storyboard

class MockImagesLibraryDatabase : ImagesLibraryDatabaseProtocol {
    var allSets: [ImageSet] = []
    var allImages: ImageSet { ImageSet(allSets.flatMap{ $0 }) }
    var setForCardsWithDoubleImages: ImageSet = []
    var setForCardsWithDoubleImagesDoubleOrder: ImageSet = []
    var setForCardsWithMultiColorBackground: ImageSet = []
    var starterSet: ImageSet = []
    var unlockedSet: ImageSet = []
    
    private(set) var loadUnlockedSetCalls = 0
    func loadUnlockedSet(from location: GameDatabase.UserDataLocation) {
        loadUnlockedSetCalls += 1
    }
    private(set) var saveUnlockedSetCalls = 0
    func saveUnlockedSet(to location: GameDatabase.UserDataLocation) {
        saveUnlockedSetCalls += 1
    }
    
    
}
