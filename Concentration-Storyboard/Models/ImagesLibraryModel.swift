//
//  ImagesLibraryModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 15/01/2024.
//

import Foundation
import CoreGraphics

typealias ImageSet = Set<ImageName>

protocol ImagesLibraryModelProtocol : AnyObject {
    func loadDatabaseValues()
    func saveDatabaseValues()
    var availableSet : ImageSet { get }
    var lockedSet : ImageSet { get }
    func unlockNewImage(for category1: ImageCategory?, and category2:ImageCategory?) -> ImageName?
    func lockedImageAvailable() -> Bool
    func filter(_ imageSet:ImageSet, for category: ImageCategory) -> ImageSet
}

typealias ImageName = String

enum ImageCategory : CaseIterable {
    case AnyImage
    case ImageForCardsWithDoubleImages
    case ImageForMulticolorBackground
    case ImageForCardsWithDoubleImagesDoubleOrder
}

class ImagesLibraryModel : ImagesLibraryModelProtocol {
    
    static private var SharedInstance = {
        ImagesLibraryModel(database: ImagesLibraryDatabase(version: GameDatabase.LibraryVersion.Default)
                           ,userDataLocation: GameDatabase.LibraryVersion.Default.userDataLocation)
    }()
    
    static var Shared : ImagesLibraryModelProtocol {
        SharedInstance
    }
    
    internal init(database: ImagesLibraryDatabaseProtocol
                  , userDataLocation: GameDatabase.UserDataLocation)
    {
        self.database = database
        self.userDataLocation = userDataLocation
        self.loadDatabaseValues()
    }
    
    private let database : ImagesLibraryDatabaseProtocol
    let userDataLocation : GameDatabase.UserDataLocation
    
    func loadDatabaseValues() {
        database.loadUnlockedSet(from: userDataLocation)
    }
    func saveDatabaseValues() {
        database.saveUnlockedSet(to: userDataLocation)
    }
    
    var availableSet: ImageSet {
        get {
            database
                .unlockedSet
                .union(database.starterSet)
                .intersection(database.allImages)
        }
    }
    var lockedSet : ImageSet {
        get {
            database
                .allImages
                .subtracting(database.unlockedSet)
                .subtracting(database.starterSet)
        }
    }

    func lockedImageAvailable() -> Bool {
        getRandomLockedImage() != nil
    }
    
    func unlockNewImage(for category1: ImageCategory? = nil, and category2:ImageCategory? = nil) -> ImageName? {
        var preferenceForCategories = [ImageCategory]()
        if let category1 { preferenceForCategories.append(category1) }
        if let category2 { preferenceForCategories.append(category2) }
        
        if let newImage = getRandomLockedImage(preferenceFor: preferenceForCategories)
        {
            database.unlockedSet.insert(newImage)
            return newImage
        } else {
            return nil
        }
    }
    
    // Will get a random image picked in all the locked image, trying to respect requested image categories if possible.
    // Image categories are used in priority order (first element of the array is the top priority category)
    internal func getRandomLockedImage(preferenceFor categories:[ImageCategory] = []) -> ImageName?
    {
        var candidatesToBeUnlocked = ImageSet()
        var stageIndex = 0
        while (stageIndex < database.allSets.count && candidatesToBeUnlocked.isEmpty) {
            candidatesToBeUnlocked = database.allSets[stageIndex].subtracting(availableSet)
            
            for category in categories {
                candidatesToBeUnlocked = filter(candidatesToBeUnlocked, for: category)
            }
            stageIndex += 1
        }

        // result : if candidates list is empty, restarting this function with less restrictions on categories
        if !candidatesToBeUnlocked.isEmpty {
            return candidatesToBeUnlocked.randomElement()
        } else {
            if !categories.isEmpty {
                var newCategoriesList = categories
                newCategoriesList.removeLast()
                return getRandomLockedImage(preferenceFor: newCategoriesList)
            } else {
                return nil
            }
        }
    }
    

    func filter(_ imageSet:ImageSet, for category: ImageCategory) -> ImageSet {
        switch(category) {
        case .AnyImage:
            return imageSet
        case .ImageForCardsWithDoubleImages:
            return imageSet.intersection( database.setForCardsWithDoubleImages )
        case .ImageForMulticolorBackground:
            return imageSet.intersection( database.setForCardsWithMultiColorBackground )
        case .ImageForCardsWithDoubleImagesDoubleOrder:
            return imageSet.intersection( database.setForCardsWithDoubleImagesDoubleOrder )
        }
    }
}
