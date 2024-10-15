//
//  LevelsLibraryDatabase.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 01/03/2024.
//

import Foundation

protocol LevelsLibraryDatabaseProtocol : AnyObject {
    var stagesParameters : [GameDatabase.StageParameters] { get }
    var levelsUnlockedIds : Set<InvariantId>  { get set }
    var levelsPoints : [InvariantId:Float] { get set }
    var levelsBestScores : [InvariantId:Float] { get set }
    func load(from location:GameDatabase.UserDataLocation)
    func save(to location:GameDatabase.UserDataLocation)
}

class LevelsLibraryDatabase : LevelsLibraryDatabaseProtocol {
    init(version: GameDatabase.LibraryVersion) {
        switch(version) {
#if DEBUG
        case .DemoV1:
            fallthrough
#endif
        case .ReleaseV1:
            self.stagesParameters = Library.ReleaseV1.StagesAndLevels.map{
                stageElement in
                GameDatabase.StageParameters(stageId: stageElement.id
                                   , levels: stageElement.levels.map{
                    levelElement in
                    GameDatabase.LevelParameters(levelId: levelElement.id
                                       , unlockedByDefault: levelElement.unlockedByDefault
                                       , cardsToDeal: levelElement.cardsToDeal
                                       , cardsByMatch: stageElement.cardsByMatch
                                       , userCanDealCards: stageElement.userCanDealCards
                                       , cardsType: stageElement.cardsType
                                       , gamePlayingMode: stageElement.gamePlayingMode)
                }
                )
            }
        }
    }
    
    let stagesParameters: [GameDatabase.StageParameters]
    var levelsUnlockedIds : Set<InvariantId> = []
    var levelsPoints : [InvariantId:Float] = [:]
    var levelsBestScores : [InvariantId:Float] = [:]
    
    internal func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func load(from location:GameDatabase.UserDataLocation) {
        self.levelsUnlockedIds = []
        self.levelsPoints = [:]
        self.levelsBestScores = [:]
        

        switch(location) {
#if DEBUG
        case .DemoV1:
            let levelsValues = Library.DemoV1.LevelsValues
            levelsValues.keys.forEach{
                let levelId = $0
                if let levelStateValues = levelsValues[$0]! {
                    self.levelsUnlockedIds.insert(levelId)
                    self.levelsPoints[levelId] = levelStateValues.points
                    self.levelsBestScores[levelId] = levelStateValues.bestScore
                }
            }
#endif
        case .UserDefaults:
            let defaults = userDefaults()
            
            // for legacy saved values
            if let levelsUnlockedStatesSourceData = defaults.dictionary(forKey: GameDatabase.DataKeys.LevelsUnlockedStates) {
                levelsUnlockedStatesSourceData.keys.forEach{
                    if (levelsUnlockedStatesSourceData[$0] as? Bool) == true {
                        self.levelsUnlockedIds.insert($0)
                    }
                }
            }
            if let levelsUnlockedIdsSourceData = defaults.array(forKey: GameDatabase.DataKeys.LevelsUnlockedIds) {
                levelsUnlockedIdsSourceData.forEach{
                    if let levelId = ($0 as? InvariantId) {
                        self.levelsUnlockedIds.insert(levelId)
                    }
                }
            }
            if let levelsPointsStatesSourceData = defaults.dictionary(forKey: GameDatabase.DataKeys.LevelsPointsStates) {
                levelsPointsStatesSourceData.keys.forEach{
                    if let levelPoints = (levelsPointsStatesSourceData[$0] as? Float) {
                        self.levelsPoints[$0] = levelPoints
                    }
                }
            }
            if let levelsBestScoresSourceData = defaults.dictionary(forKey: GameDatabase.DataKeys.LevelsBestScores) {
                levelsBestScoresSourceData.keys.forEach{
                    if let levelBestScore = (levelsBestScoresSourceData[$0] as? Float) {
                        self.levelsBestScores[$0] = levelBestScore
                    }
                }
            }
        }
    }
    
    func save(to location:GameDatabase.UserDataLocation) {
        switch(location) {
#if DEBUG
        case .DemoV1:
            break
#endif
        case .UserDefaults:
            let defaults = userDefaults()
            
            defaults.set(self.levelsUnlockedIds.sorted(), forKey: GameDatabase.DataKeys.LevelsUnlockedIds)
            defaults.set(self.levelsPoints, forKey: GameDatabase.DataKeys.LevelsPointsStates)
            defaults.set(self.levelsBestScores, forKey: GameDatabase.DataKeys.LevelsBestScores)
            // erasing legacy values
            defaults.set(nil, forKey: GameDatabase.DataKeys.LevelsUnlockedStates)
        }
    }

}

extension LevelsLibraryDatabase {
    struct Library {
        struct ReleaseV1 {
            static let StagesAndLevels : [(id: InvariantId
                                           , cardsByMatch: Int
                                           , userCanDealCards: Bool
                                           , cardsType: CardType
                                           , gamePlayingMode: GamePlayingMode
                                           , levels: [(id: InvariantId, unlockedByDefault: Bool, cardsToDeal: Int)]
                                          )] =
            [
                (id: "v1.00_stage00"
                 , cardsByMatch: 2
                 , userCanDealCards: false
                 , cardsType: .SingleImage
                 , gamePlayingMode: .SinglePlayer
                 , levels: [
                    (id: "v1.00_level00.00", unlockedByDefault: true, cardsToDeal: 8)
                    , (id: "v1.00_level00.10", unlockedByDefault: false, cardsToDeal: 12)
                    , (id: "v1.00_level00.20", unlockedByDefault: false, cardsToDeal: 18)
                    , (id: "v1.00_level00.30", unlockedByDefault: false, cardsToDeal: 22)
                 ])
                ,(id: "v1.00_stage10"
                  , cardsByMatch: 2
                  , userCanDealCards: false
                  , cardsType: .SingleImageMultiColors(colorsCount: 2)
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level10.00", unlockedByDefault: true, cardsToDeal: 8)
                    , (id: "v1.00_level10.10", unlockedByDefault: false, cardsToDeal: 12)
                    , (id: "v1.00_level10.20", unlockedByDefault: false, cardsToDeal: 16)
                    , (id: "v1.00_level10.30", unlockedByDefault: false, cardsToDeal: 24)
                  ])
                ,(id: "v1.00_stage20"
                  , cardsByMatch:3
                  , userCanDealCards: false
                  , cardsType: .SingleImage
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level20.00", unlockedByDefault: false, cardsToDeal:9)
                    , (id: "v1.00_level20.10", unlockedByDefault: false, cardsToDeal:15)
                    , (id: "v1.00_level20.20", unlockedByDefault: false, cardsToDeal:18)
                    , (id: "v1.00_level20.30", unlockedByDefault: false, cardsToDeal:21)
                  ])
                ,(id: "v1.00_stage30"
                  , cardsByMatch:  2
                  , userCanDealCards: false
                  , cardsType: .DualImage
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level30.00", unlockedByDefault: false, cardsToDeal: 8)
                    , (id: "v1.00_level30.10", unlockedByDefault: false, cardsToDeal: 12)
                    , (id: "v1.00_level30.20", unlockedByDefault: false, cardsToDeal: 14)
                  ])
                ,(id: "v1.00_stage40"
                  , cardsByMatch: 2
                  , userCanDealCards: false
                  , cardsType: .SingleImageMultiColors(colorsCount: 4)
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level40.00", unlockedByDefault: false, cardsToDeal: 10)
                    , (id: "v1.00_level40.10", unlockedByDefault: false, cardsToDeal: 14)
                    , (id: "v1.00_level40.20", unlockedByDefault: false, cardsToDeal: 18)
                  ])
                ,(id: "v1.00_stage50"
                  , cardsByMatch: 4
                  , userCanDealCards: false
                  , cardsType: .SingleImage
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level50.00", unlockedByDefault: false, cardsToDeal: 12)
                    , (id: "v1.00_level50.10", unlockedByDefault: false, cardsToDeal: 16)
                    , (id: "v1.00_level50.20", unlockedByDefault: false, cardsToDeal: 20)
                  ])
                ,(id: "v1.00_stage60"
                  , cardsByMatch: 2
                  , userCanDealCards: false
                  , cardsType: .DualImageMultiOrder
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level60.00", unlockedByDefault: false, cardsToDeal: 10)
                    , (id: "v1.00_level60.10", unlockedByDefault: false, cardsToDeal: 12)
                    , (id: "v1.00_level60.20", unlockedByDefault: false, cardsToDeal: 14)
                  ])
                ,(id: "v1.00_stage70"
                  , cardsByMatch: 3
                  , userCanDealCards: false
                  , cardsType: .DualImage
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level70.00", unlockedByDefault: false, cardsToDeal: 9)
                    , (id: "v1.00_level70.10", unlockedByDefault: false, cardsToDeal: 12)
                    , (id: "v1.00_level70.20", unlockedByDefault: false, cardsToDeal: 15)
                  ])
                ,(id: "v1.00_stage80"
                  , cardsByMatch: 3
                  , userCanDealCards: false
                  , cardsType: .SingleImageMultiColors(colorsCount: 3)
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level80.00", unlockedByDefault: false, cardsToDeal: 9)
                    , (id: "v1.00_level80.10", unlockedByDefault: false, cardsToDeal: 15)
                    , (id: "v1.00_level80.20", unlockedByDefault: false, cardsToDeal: 18)
                  ])
                ,(id: "v1.00_stage90"
                  , cardsByMatch: 3
                  , userCanDealCards: false
                  , cardsType: .DualImageMultiOrder
                  , gamePlayingMode: .SinglePlayer
                  , levels: [
                    (id: "v1.00_level90.00", unlockedByDefault: false, cardsToDeal: 9)
                    , (id: "v1.00_level90.10", unlockedByDefault: false, cardsToDeal: 12)
                    , (id: "v1.00_level90.20", unlockedByDefault: false, cardsToDeal: 15)
                  ])
                ,(id: "v1.00_stage100"
                 , cardsByMatch: 2
                 , userCanDealCards: false
                 , cardsType: .SingleImage
                 , gamePlayingMode: .SinglePlayer
                 , levels: [
                    (id: "v1.00_level100.00", unlockedByDefault: false, cardsToDeal: 40)
                    , (id: "v1.00_level100.10", unlockedByDefault: false, cardsToDeal: 56)
                 ])
            ]
        }
        
        struct DemoV1 {
            static let LevelsValues : [InvariantId:(points:Float,bestScore:Float)?] = [
                "v1.00_level00.00":(points:999, bestScore:1)
                , "v1.00_level00.10":(points:999, bestScore:0.95)
                , "v1.00_level00.20":(points:999, bestScore:1)
                , "v1.00_level00.30":(points:999, bestScore:0.85)
                , "v1.00_level00.40":(points:40, bestScore:0.55)
                , "v1.00_level10.00":(points:999, bestScore:0.79)
                , "v1.00_level10.10":(points:999, bestScore:0.75)
                , "v1.00_level10.20":(points:999, bestScore:0.45)
                , "v1.00_level10.30":nil
                , "v1.00_level20.00":(points:90, bestScore:0.85)
                , "v1.00_level20.10":(points:45, bestScore:0.4)
                , "v1.00_level20.20":(points:45, bestScore:0.4)
                , "v1.00_level20.30":(points:45, bestScore:0.4)
                , "v1.00_level30.00":(points:999, bestScore:1)
                , "v1.00_level30.10":(points:999, bestScore:1)
                , "v1.00_level30.20":(points:999, bestScore:0.75)
                , "v1.00_level30.30":(points:80, bestScore:0.55)
                , "v1.00_level40.00":(points:45, bestScore:0.4)
                , "v1.00_level40.10":nil
                , "v1.00_level40.20":nil
                , "v1.00_level50.00":(points:73, bestScore:0.95)
                , "v1.00_level50.10":nil
                , "v1.00_level50.20":(points: LevelState.NeededPointsToCompleteDefaultValue - 1, bestScore:0.1)
                , "v1.00_level60.00":nil
                , "v1.00_level60.10":nil
                , "v1.00_level60.20":nil
                , "v1.00_level70.00":nil
                , "v1.00_level70.10":nil //(points: 0, bestScore:0)
//                , "v1.00_level100.00":(points:3, bestScore:0.45)
                , "v1.00_level100.10":(points:0, bestScore:0)
            ]
        }
    }
}

