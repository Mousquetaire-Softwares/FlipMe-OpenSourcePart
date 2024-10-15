//
//  ImagesLibrarySharedPickerModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 12/03/2024.
//

import Foundation


// implentation of ImagesLibraryPickerModelProtocol as a class, to use a shared image picker between multiple instance of decks (usefull for card examples of the main menu to renew images)
class ImagesLibrarySharedPickerModel : ImagesLibraryPickerModelProtocol {
    var library: ImagesLibraryModelProtocol {
        picker.library
    }
    
    var delivered: Set<ImageName> {
        picker.delivered
    }
    
    init(using library: ImagesLibraryModelProtocol)
    {
        picker = ImagesLibraryPickerModel(using: library)
    }
    
    private var picker : ImagesLibraryPickerModel
    
    func reset(renewingImages:Bool) {
        picker.reset(renewingImages: renewingImages)
    }
        
    func remainingCount(for category:ImageCategory) -> Int {
        picker.remainingCount(for: category)
    }
        
    
    func popRandom(for category:ImageCategory) -> ImageName? {
        picker.popRandom(for:category)
    }
}
