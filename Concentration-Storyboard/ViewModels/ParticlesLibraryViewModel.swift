//
//  ParticlesLibraryViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 29/03/2024.
//

import Foundation
import UIKit

struct ParticlesLibraryViewModel {
    enum HappyFaces : CaseIterable {
        case Blue,Green,Pink,Yellow
        static var UIImages : [UIImage] = DataUIImagesByColor.allValues
        var UIImages : [UIImage] { Self.DataUIImagesByColor[self, default: []] }
        
        static private let DataUIImagesByColor = DataImagesNamesByColor.mapValues{ $0.compactMap{ UIImage(named: $0) } }
        static private let DataImagesNamesByColor = [
            Self.Blue : [ "blue-happyface-1"
                          ,"blue-happyface-2" ]
            , .Green : [ "green-happyface-1"
                         ,"green-happyface-2" ]
            , .Pink : [ "pink-happyface-1"
                        ,"pink-happyface-2" ]
            , .Yellow : [ "yellow-happyface-1"
                          ,"yellow-happyface-2"
                          ,"yellow-happyface-3"
                          ,"yellow-happyface-4" ]
        ]
        

    }
    enum Stars : CaseIterable {
        case Blue, Green, Pink, Yellow
        static var UIImages : [UIImage] = DataUIImagesByColor.allValues
        var UIImages : [UIImage] { Self.DataUIImagesByColor[self, default: []] }
        
        static private let DataUIImagesByColor = DataImagesNamesByColor.mapValues{ $0.compactMap{ UIImage(named: $0) } }
        static private let DataImagesNamesByColor = [
            Self.Blue: [ "blue-star-1" ]
            , .Green: [ "green-star-1" ]
            , .Pink : [ "pink-star-1" ]
            , .Yellow : [ "yellow-star-1"
                         ,"yellow-star-2" ]
        ]
    }
    enum BadFaces : CaseIterable {
        case Red, Grey, Purple
        static var UIImages : [UIImage] = DataUIImagesByColor.allValues
        var UIImages : [UIImage] { Self.DataUIImagesByColor[self, default: []] }
        
        static private let DataUIImagesByColor = DataImagesNamesByColor.mapValues{ $0.compactMap{ UIImage(named: $0) } }
        static private let DataImagesNamesByColor = [
            Self.Red : [ "red-badface-1"
                         ,"red-badface-2"
                         ,"red-badface-3"
                         ,"red-badface-4"
                         ,"red-badface-5"
                         ,"red-badface-6"
                         ,"red-badface-7" ]
            , .Grey : [ "grey-badface-1" ]
            , .Purple : [ "purple-badface-1"
                          ,"purple-badface-2" ]
        ]
    }
    enum Exclamations : CaseIterable {
        case Grey
        static var UIImages : [UIImage] = DataUIImagesByColor.allValues
        var UIImages : [UIImage] { Self.DataUIImagesByColor[self, default: []] }
        
        static private let DataUIImagesByColor = DataImagesNamesByColor.mapValues{ $0.compactMap{ UIImage(named: $0) } }
        static private let DataImagesNamesByColor = [
            Self.Grey : [ "grey-exclamation-1"
                          ,"grey-exclamation-2"
                          ,"grey-exclamation-3"
                          ,"grey-exclamation-4" ]
        ]
    }
    enum Rainbows : CaseIterable {
        static var UIImages : [UIImage] = DataUIImages
        
        static private let DataUIImages = DataImagesNames.compactMap{ UIImage(named: $0) }
        static fileprivate let DataImagesNames = [
            "multicolor-rainbow-1"
            ,"multicolor-rainbow-2"
        ]
    }
}

#if DEBUG
extension ParticlesLibraryViewModel.HappyFaces {
    internal static var InternalDataImagesNamesByColor : [Self:[ImageName]] { DataImagesNamesByColor }
}
extension ParticlesLibraryViewModel.Stars {
    internal static var InternalDataImagesNamesByColor : [Self:[ImageName]] { DataImagesNamesByColor }
}
extension ParticlesLibraryViewModel.BadFaces {
    internal static var InternalDataImagesNamesByColor : [Self:[ImageName]] { DataImagesNamesByColor }
}
extension ParticlesLibraryViewModel.Exclamations {
    internal static var InternalDataImagesNamesByColor : [Self:[ImageName]] { DataImagesNamesByColor }
}
extension ParticlesLibraryViewModel.Rainbows {
    internal static var InternalDataImagesNames : [ImageName] { DataImagesNames }
}
#endif
