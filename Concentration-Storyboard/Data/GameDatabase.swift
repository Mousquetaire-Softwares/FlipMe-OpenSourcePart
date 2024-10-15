//
//  GameDatabase.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 24/04/2024.
//

import Foundation

class GameDatabase {
    enum LibraryVersion {
        case ReleaseV1
        
#if DEBUG
        case DemoV1
        static var Default : Self { .DemoV1 }
#else
        static var Default : Self { .ReleaseV1 }
#endif
        
        var userDataLocation : UserDataLocation {
            switch(self) {
            case .ReleaseV1:
                return .UserDefaults
#if DEBUG
            case .DemoV1:
                return .DemoV1
#endif
            }
        }
    }
    
    
    struct DataKeys {
#if DEBUG
        private static let KeysPrefix = "DEBUG-"
#else
        private static let KeysPrefix = ""
#endif
        static let LevelsUnlockedStates = KeysPrefix + "LevelsUnlockedStates"  // for legacy values
        static let LevelsUnlockedIds = KeysPrefix + "LevelsUnlockedIds"
        static let LevelsPointsStates = KeysPrefix + "LevelsPointsStates"
        static let LevelsBestScores = KeysPrefix + "LevelsBestScores"
        static let ImagesNamesUnlocked = KeysPrefix + "ImagesNamesUnlocked"
        static let NumberOfLevelsPlayedSinceLastReviewRequest = KeysPrefix + "NumberOfLevelsPlayedSinceLastReviewRequest"
        static let NumberOfReviewRequests = KeysPrefix + "NumberOfReviewRequests"
    }
    
    enum UserDataLocation {
        case UserDefaults
#if DEBUG
        case DemoV1
#endif
    }
    
    struct LevelParameters {
        var levelId: InvariantId
        var unlockedByDefault: Bool
        var cardsToDeal: Int
        var cardsByMatch: Int
        var userCanDealCards: Bool
        var cardsType: CardType
        var gamePlayingMode: GamePlayingMode
    }
    
    struct StageParameters {
        let stageId: InvariantId
        let levels: [LevelParameters]
    }
}
