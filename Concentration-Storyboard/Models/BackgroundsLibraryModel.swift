//
//  BackgroundsLibraryModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 03/04/2024.
//

import Foundation
import CoreGraphics



class BackgroundsLibraryModel {
    static var Shared : BackgroundsLibraryModel = BackgroundsLibraryModel()
    
    fileprivate init() {
        menuData = Library.MenuStarterSet
        gametableData = Library.GametableStarterSet
    }
    
    private var menuData: [(ImageName,CGColor)]
    private var gametableData: ImageSet
    
    func menuAvailableSet() -> [(image:ImageName,color:CGColor)] {
        return menuData
    }
    func gametableAvailableSet() -> ImageSet {
        return gametableData
    }

}

extension BackgroundsLibraryModel {
    struct Library {
        static let MenuStarterSet = AllData
        static let GametableStarterSet: ImageSet = ImageSet(AllData.map{ $0.image })

        static let AllData : [(image:ImageName,color:CGColor)] = [
            (image:"background002", color: #colorLiteral(red: 0.8635006444, green: 0.9277075451, blue: 1, alpha: 1)
            ),
            (image:"background003", color: #colorLiteral(red: 0.9002330579, green: 0.988452026, blue: 1, alpha: 1)
            ),
            (image:"background004", color: #colorLiteral(red: 0.8532872105, green: 1, blue: 0.84899325, alpha: 1)
            ),
            (image:"background005", color: #colorLiteral(red: 1, green: 0.9664455289, blue: 0.8772647791, alpha: 1)
            ),
            (image:"background006", color: #colorLiteral(red: 1, green: 0.9768964182, blue: 0.8571399955, alpha: 1)
            ),
            (image:"background007", color: #colorLiteral(red: 0.780165657, green: 0.8516135479, blue: 1, alpha: 1)
            ),
            (image:"background008", color: #colorLiteral(red: 0.9228976695, green: 0.9793990332, blue: 1, alpha: 1)
            ),
            (image:"background009", color: #colorLiteral(red: 1, green: 0.9677255771, blue: 0.8882845441, alpha: 1)
            )
        ]
    }
}
