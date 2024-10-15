//
//  ImagesLibraryDatabase.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 01/03/2024.
//

import Foundation

protocol ImagesLibraryDatabaseProtocol : AnyObject {
    var allSets: [ImageSet] { get }
    var allImages: ImageSet { get }
    var setForCardsWithDoubleImages: ImageSet { get }
    var setForCardsWithDoubleImagesDoubleOrder: ImageSet { get }
    var setForCardsWithMultiColorBackground: ImageSet { get }
    var starterSet: ImageSet { get }
    var unlockedSet: ImageSet { get set }
    
    func loadUnlockedSet(from location:GameDatabase.UserDataLocation)
    func saveUnlockedSet(to location:GameDatabase.UserDataLocation)
}

class ImagesLibraryDatabase : ImagesLibraryDatabaseProtocol {
    
    init(version:GameDatabase.LibraryVersion) {
        switch(version) {
        case .ReleaseV1:
            self.allSets = Library.ReleaseV1.AllSets
            self.allImages = ImageSet(allSets.flatMap({ $0 }))
            self.setForCardsWithDoubleImages = Library.ReleaseV1.SetForCardsWithDoubleImages
            self.setForCardsWithDoubleImagesDoubleOrder = Library.ReleaseV1.SetForCardsWithDoubleImagesDoubleOrder
            self.setForCardsWithMultiColorBackground = Library.ReleaseV1.SetForCardsWithMultiColorBackground
            self.starterSet = Library.ReleaseV1.StarterSet
            self.unlockedSet = []
#if DEBUG
        case .DemoV1:
            self.allSets = Library.DemoV1.AllSets
            self.allImages = ImageSet(allSets.flatMap({ $0 }))
            self.setForCardsWithDoubleImages = Library.ReleaseV1.SetForCardsWithDoubleImages
            self.setForCardsWithDoubleImagesDoubleOrder = Library.ReleaseV1.SetForCardsWithDoubleImagesDoubleOrder
            self.setForCardsWithMultiColorBackground = Library.ReleaseV1.SetForCardsWithMultiColorBackground
            self.starterSet = Library.DemoV1.StarterSet
            self.unlockedSet = []
#endif
        }
    }
    
    let allSets : [ImageSet]
    let allImages : ImageSet
    let setForCardsWithDoubleImages: ImageSet
    let setForCardsWithDoubleImagesDoubleOrder: ImageSet
    let setForCardsWithMultiColorBackground: ImageSet
    let starterSet : ImageSet
    
    var unlockedSet : ImageSet
    
    
   
    
    internal func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func loadUnlockedSet(from location:GameDatabase.UserDataLocation) {
        switch(location) {
#if DEBUG
        case .DemoV1:
            break
#endif
        case .UserDefaults:
            let defaults = userDefaults()
            let imagesNamesUnlocked = defaults.array(forKey: GameDatabase.DataKeys.ImagesNamesUnlocked) as? [ImageName]
            self.unlockedSet = ImageSet(imagesNamesUnlocked ?? [])
        }
    }
    
    func saveUnlockedSet(to location:GameDatabase.UserDataLocation) {
        switch(location) {
#if DEBUG
        case .DemoV1:
            break
#endif
        case .UserDefaults:
            let defaults = userDefaults()
            defaults.set(Array(self.unlockedSet), forKey: GameDatabase.DataKeys.ImagesNamesUnlocked)
        }
    }
}

extension ImagesLibraryDatabase {
    struct Library {
        typealias SetIndex = Int
        private static let StarterSetIndex = 0
        
        struct ReleaseV1 {
            static let StarterSet: ImageSet = AllSets[StarterSetIndex]
            
            fileprivate static let AllSets : [ImageSet] = {
                
                var data = [[String:ImageSet]](repeating: [:], count: 5)
                
                data[StarterSetIndex]["cars"] = ["015","016","021"]
                data[1]["cars"] = ["018"]
                data[2]["cars"] = ["020"]
                data[3]["cars"] = ["019"] //,"024"]
                data[4]["cars"] = ["017"] //,"022","023"]
                
                data[StarterSetIndex]["birds"] = ["034"]
                data[1]["birds"] = ["035"]
                data[2]["birds"] = [] //["033"]
                data[3]["birds"] = ["042"]
                data[4]["birds"] = ["054"]
                
                data[StarterSetIndex]["hands"] = ["044"]
                data[1]["hands"] = ["048"]
                data[2]["hands"] = ["043"]
                data[3]["hands"] = ["063"]
                data[4]["hands"] = ["039","041"]
                
                data[StarterSetIndex]["katanas"] = []
                data[1]["katanas"] = ["045"]
                data[2]["katanas"] = []
                data[3]["katanas"] = ["046"]
                data[4]["katanas"] = ["047"]
                
                data[StarterSetIndex]["boxes"] = ["057"]
                data[1]["boxes"] = []
                data[2]["boxes"] = ["056"]
                data[3]["boxes"] = ["067"]
                data[4]["boxes"] = ["068"]
                
                data[StarterSetIndex]["flowers"] = ["058"]
                data[1]["flowers"] = []
                data[2]["flowers"] = []
                data[3]["flowers"] = ["059"]
                data[4]["flowers"] = []
                
                data[StarterSetIndex]["exclamations"] = []
                data[1]["exclamations"] = []
                data[2]["exclamations"] = ["066"]
                data[3]["exclamations"] = []
                data[4]["exclamations"] = ["069"]
                
                data[StarterSetIndex]["circles"] = ["006"]
                data[1]["circles"] = ["003"]
                data[2]["circles"] = []
                data[3]["circles"] = ["040"]
                data[4]["circles"] = ["036"]
                
                data[StarterSetIndex]["boats"] = ["037"]
                data[1]["boats"] = []
                data[2]["boats"] = []
                data[3]["boats"] = []
                data[4]["boats"] = ["009"]
                
                data[StarterSetIndex]["others"] = ["005","007","008","013","012","004","027","026","051","061","062","064","070","071"]
                data[1]["others"] = ["031","050","055"]
                data[2]["others"] = ["038","049"] //] //"029",
                data[3]["others"] = ["052"] //,"060"]
                data[4]["others"] = ["030", "072"]
                
                return data.map{
                    imagesSet in
//                    debugPrint(ImageSet(imagesSet.values.flatMap{ $0 }).count)
//                    debugPrint(imagesSet.values.flatMap{ $0 }.sorted())
                    return ImageSet(imagesSet.values.flatMap{ $0 })
                }
                
            }()
            
            fileprivate static let SetForCardsWithDoubleImages: ImageSet = ["001","003","004","005","007","008","009","012","013","017","023","026","027","029","030","031","033","034","036","037","038","039","040","041","042","043","044","047","048","050","051","052","054","055","057","058","061","062","063","066","068","069","071","072"]
            
            fileprivate static let SetForCardsWithDoubleImagesDoubleOrder: ImageSet = ["001","005","007","008","009","012","013","020","026","027","037","038","041","042","044","050","051","052","054","055","056","058","061","062","064","068","071","072"]
            
            fileprivate static let SetForCardsWithMultiColorBackground: ImageSet = ["001","004","005","007","008","009","012","016","019","024","026","029","030","034","035","037","041","042","043","044","045","046","048","049","050","051","052","054","055","056","058","059","060","061","062","063","064","066","067","068","070","071","072"]
        }
        
#if DEBUG
        struct DemoV1 {
            static let StarterSet: ImageSet = AllSets[StarterSetIndex]
            
            fileprivate static let AllSets : [ImageSet] = {
                
                var data = [[String:ImageSet]](repeating: [:], count: 3)
                
                let FirstLockedSetIndex = 1
                let setName = "any"
                
                data[FirstLockedSetIndex][setName] = [
                    "067","054","037","017","027"
                ]
                data[StarterSetIndex][setName] = Set([
                    "005","008","012","013","016","017","020","021","023","026","027","030","035","036","037","039","040","045","048","054","061","062","064","067","070","071","015","016","021"
                ]).subtracting(data[FirstLockedSetIndex][setName]!)
                
                data[2][setName] = Set(ReleaseV1.AllSets.flatMap{ $0 })
                    .subtracting(data[FirstLockedSetIndex][setName]!)
                    .subtracting(data[StarterSetIndex][setName]!)
                
                return data.map{
                    imagesSet in
                    return ImageSet(imagesSet.values.flatMap{ $0 })
                }
                
            }()
        }
#endif
        
    }
}

