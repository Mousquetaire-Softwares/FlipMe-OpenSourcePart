//
//  ImagesLibraryPickerModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 07/02/2024.
//

import Foundation


protocol ImagesLibraryPickerModelProtocol {
    var library : ImagesLibraryModelProtocol { get }
    var delivered : ImageSet { get }
    func remainingCount(for:ImageCategory) -> Int
    mutating func popRandom(for:ImageCategory) -> ImageName?
    mutating func reset(renewingImages:Bool)
}

/// Will deliver random images to the DeckModel, using a given library
/// Can reset with option to renew delivered images (the previously delivered images won't be choosen first)
struct ImagesLibraryPickerModel : ImagesLibraryPickerModelProtocol {
    
    init(using library: ImagesLibraryModelProtocol)
    {
        self.library = library
        reset(renewingImages:false)
    }
    
    let library : ImagesLibraryModelProtocol
    
    mutating func reset(renewingImages:Bool) {
        reset(renewingImages: renewingImages, rememberingPreviousDeals: Parameter.RememberingPreviousDealsDefaultValue)
    }
    mutating func reset(renewingImages:Bool, rememberingPreviousDeals:Int) {
        formerDelivered.insert(delivered, at: 0)
        delivered = []
        
        while formerDelivered.count > rememberingPreviousDeals {
            formerDelivered.removeLast()
        }
        
        if renewingImages {
            valuesToPickByPriority = []
            var allSeenValues = ImageSet()
            formerDelivered.forEach{
                valuesToPickByPriority.insert($0.subtracting(allSeenValues), at: 0)
                allSeenValues.formUnion($0)
            }
            
            valuesToPickByPriority.insert(library.availableSet.subtracting(allSeenValues), at: 0)
        } else {
            valuesToPickByPriority = [library.availableSet]
        }
        
    }
    
    private(set) var delivered : ImageSet = []
    private var formerDelivered : [ImageSet] = []
    
    func remainingCount(for category:ImageCategory) -> Int {
        library
            .filter(availableValues
                    , for:category)
            .count
    }
        
    internal private(set) var valuesToPickByPriority : [ImageSet] = []
    
    private var availableValues : ImageSet {
        ImageSet(valuesToPickByPriority.flatMap{ $0 })
    }
    
    mutating func popRandom(for category:ImageCategory) -> ImageName? {
        for priority in valuesToPickByPriority.indices {
            if let result = library.filter(valuesToPickByPriority[priority], for:category).randomElement() {
                valuesToPickByPriority[priority].remove(result)
                delivered.insert(result)
                return result
            }
        }
        return nil
    }
}

extension ImagesLibraryPickerModel {
    struct Parameter {
        static let RememberingPreviousDealsDefaultValue = 4
    }
}


