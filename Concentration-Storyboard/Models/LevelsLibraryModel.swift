
import Foundation

/// Key to identify a Stage in the LevelsLibrary Model
typealias StageKey = Int
/// Key to identify a Level in the LevelsLibrary Model
struct LevelKey : Equatable, Hashable { let stage:StageKey, level:Int }
/// Unique Id of a level, invariant through future versions of the game, used to save values in user profile
typealias InvariantId = String

enum GameReward {
    case NewImage(ImageName?)
    case NewUnknownImage
    case LevelCompleted
    case NewLevelUnlocked(LevelKey)
    case NewStageUnlocked(StageKey)
    case NewBestScore
}

struct LevelsLibraryModel {
    enum Err : Error {
        case WrongKey
    }
    
    static private var SharedInstance = {
        LevelsLibraryModel(with: LevelsLibraryDatabase(version: GameDatabase.LibraryVersion.Default)
                           , imagesLibrary: ImagesLibraryModel.Shared
                           , userDataLocation: GameDatabase.LibraryVersion.Default.userDataLocation)
    }()
    
    static var Shared : LevelsLibraryModel {
        SharedInstance
    }
        
    internal init(with database: LevelsLibraryDatabaseProtocol
                 , imagesLibrary: ImagesLibraryModelProtocol
                  , userDataLocation: GameDatabase.UserDataLocation)
    {
        self.database = database
        self.stages = database.stagesParameters.enumerated().map{
            stageParameters in
            StageModel(key: stageParameters.offset
                       , id: stageParameters.element.stageId
                       , levels: stageParameters.element.levels.enumerated().map{
                LevelModel(key: LevelKey(stage: stageParameters.offset, level: $0.offset)
                           , id: $0.element.levelId
                           , unlocked: $0.element.unlockedByDefault
                           , cardsToDeal: $0.element.cardsToDeal
                           , cardsByMatch: $0.element.cardsByMatch
                           , userCanDealCards: $0.element.userCanDealCards
                           , cardsType: $0.element.cardsType
                           , gamePlayingMode: $0.element.gamePlayingMode)
            })
        }
        self.imagesLibrary = imagesLibrary
        self.userDataLocation = userDataLocation
        self.loadDatabaseLevelsStates(from: userDataLocation)
    }
    
    private(set) var stages : [StageModelProtocol]
    let imagesLibrary : ImagesLibraryModelProtocol
    let userDataLocation : GameDatabase.UserDataLocation
    
    func potentialReward(completing levelKey:LevelKey) -> [GameReward] {
        guard let level = try? self[levelKey] else { return [] }
        
        var result = [GameReward]()
        
        // If current best score is not rank Four, a new best score is possible
        if let bestScore = level.state.bestScore, case .Four = bestScore.rank { }
        else {
            result.append(GameReward.NewBestScore)
        }
        
        // Look if level could be completed. If not, there is no more potential reward
        if (level.state.completed) == false {
            result.append(.LevelCompleted)
            
            // Look if there's a next level to unlock
            if let nextLevelKey = nextLevel(of: levelKey)
                , let nextLevel = try? self[nextLevelKey] 
            {
                if (nextLevel.state.unlocked) == false {
                    result.append(.NewLevelUnlocked(nextLevelKey))
                }
            }
            
            // Look if there is a new image to unlock
            if imagesLibrary.lockedImageAvailable() {
                result.append(.NewUnknownImage)
            }
        }
        
        return result
    }
    
    
    /// Record result of a game when  user finishes a level
    /// Updates stages and levels objects using a given score : complete a level, unlock a new one, unlock a new image... and result the rewards to the user
    mutating func gameAchievement(of levelKey:LevelKey, withFinalScore score: GameScoreModelProtocol) -> [GameReward] {
        var result = [GameReward]()
        do {
            let level = try self[levelKey]
            let levelStatePreviousValue = level.state
            var levelStateToUpdate = levelStatePreviousValue
            
            levelStateToUpdate.points += score.points
            
            if levelStatePreviousValue.bestScore == nil || score.score > levelStatePreviousValue.bestScore!.score {
                levelStateToUpdate.bestScore = score
                if levelStatePreviousValue.bestScore != nil {
                    result.append(.NewBestScore)
                }
            }
            
            var levelToUnlockStateToUpdate : LevelState? = nil
            var levelToUnlockImagesCategory : ImageCategory? = nil
            
            if levelStateToUpdate.completed && !levelStatePreviousValue.completed {
                result.append(.LevelCompleted)
                
                if let levelToUnlockKey = nextLevel(of:levelKey) {
                    let levelToUnlock = try self[levelToUnlockKey]
                    if !levelToUnlock.state.unlocked {
                        levelToUnlockStateToUpdate = levelToUnlock.state
                        levelToUnlockImagesCategory = levelToUnlock.cardsType.imagesCategory
                        levelToUnlockStateToUpdate!.unlocked = true
                        result.append(.NewLevelUnlocked(levelToUnlockStateToUpdate!.levelKey))
                        
                        if levelToUnlock.key.stage != level.key.stage {
                            result.append(.NewStageUnlocked(levelToUnlock.key.stage))
                        }
                    }
                }
                
                let newImage = imagesLibrary.unlockNewImage(for: level.cardsType.imagesCategory
                                                            , and: levelToUnlockImagesCategory)
                if let newImage {
                    result.append(.NewImage(newImage))
                }
            }
            if let levelToUnlockStateToUpdate {
                try setLevelState(levelToUnlockStateToUpdate)
            }
            try setLevelState(levelStateToUpdate)
        } catch {
            self.loadDatabaseLevelsStates(from: userDataLocation)
            imagesLibrary.loadDatabaseValues()
            return []
        }
        
        self.saveDatabaseLevelsStates(to: userDataLocation)
        imagesLibrary.saveDatabaseValues()
        return result
    }
    
    private var database : LevelsLibraryDatabaseProtocol
    
    // call database loading method then updates stages values from database levels values
    mutating func loadDatabaseLevelsStates(from location:GameDatabase.UserDataLocation) {
        database.load(from: location)

        for stageIndex in self.stages.indices {
            for levelIndex in stages[stageIndex].levels.indices {
                let levelId = stages[stageIndex].levels[levelIndex].id
                var levelState = stages[stageIndex].levels[levelIndex].state
                
                // unlocked levels
                levelState.unlocked = database.stagesParameters[stageIndex].levels[levelIndex].unlockedByDefault || database.levelsUnlockedIds.contains(levelId)

                // points
                levelState.points = database.levelsPoints[levelId] ?? LevelState.StartingPointsDefaultValue

                // best scores
                if let levelBestScore = database.levelsBestScores[levelId] {
                    levelState.bestScore =  GameBestScoreModel(score: levelBestScore)
                }
                
                try? self.stages[stageIndex].levels[levelIndex].setState(levelState)
            }
        }
        
        try? correctUnlockedLevelsIfNecessary()
    }

    // updates database from stages values then calls database saving method
    func saveDatabaseLevelsStates(to location:GameDatabase.UserDataLocation) {
        // unlocked levels
        let lockedLevelsIds = stages
            .flatMap{ $0.levels }
            .filter{ $0.state.unlocked == false }
            .map{ $0.id }
        let unlockedLevelsIds = stages
            .flatMap{ $0.levels }
            .filter{ $0.state.unlocked == true }
            .map{ $0.id }
        database.levelsUnlockedIds.formUnion(unlockedLevelsIds)
        database.levelsUnlockedIds.subtract(lockedLevelsIds)
        
        // points
        let levelsPointsKeysValues = stages
            .flatMap{ $0.levels }
            .map{ ($0.id, $0.state.points) }
        database.levelsPoints = [InvariantId:Float](levelsPointsKeysValues, uniquingKeysWith: { $1 })
        
        // best scores
        let levelsBestScoresKeysValues = stages
            .flatMap{ $0.levels }
            .filter{ $0.state.bestScore != nil }
            .map{ ($0.id, $0.state.bestScore!.score) }
        database.levelsBestScores = [InvariantId:Float](levelsBestScoresKeysValues, uniquingKeysWith: { $1 })
        
        database.save(to: location)
    }
    
    // If a level is complete and its next level is not unlocked, it's an error and user will never get to this next level
    // This can happen when modifying levels library structure or completion levels rules
    // This function will correct it by unlocking those levels
    // Careful though : new images aren't unlocked, so user can finish all levels and still have some locked images
    private mutating func correctUnlockedLevelsIfNecessary() throws {
        for stageIndex in stages.indices {
            for levelIndex in stages[stageIndex].levels.indices {
                let levelKey = stages[stageIndex].levels[levelIndex].key
                let levelState = stages[stageIndex].levels[levelIndex].state
                if let nextLevelKey = nextLevel(of: levelKey) {
                    var nextLevelState = try self[nextLevelKey].state
                    
                    if levelState.completed && !nextLevelState.unlocked {
                        nextLevelState.unlocked = true
                        try setLevelState(nextLevelState)
                    }
                }
            }
        }
    }
    
    
    subscript(levelKey:LevelKey) -> LevelModelProtocol {
        get throws {
            if stages.indices.contains(levelKey.stage)
                , stages[levelKey.stage].levels.indices.contains(levelKey.level)
            {
                return stages[levelKey.stage].levels[levelKey.level]
            } else {
                throw Err.WrongKey
            }
        }
    }
    
    private mutating func setLevelState(_ newState:LevelState) throws {
        let levelKey = newState.levelKey
        if stages.indices.contains(levelKey.stage)
            , stages[levelKey.stage].levels.indices.contains(levelKey.level)
        {
            let levelId = stages[levelKey.stage].levels[levelKey.level].id
            try stages[levelKey.stage].levels[levelKey.level].setState(newState)
            if newState.unlocked {
                database.levelsUnlockedIds.insert(levelId)
            } else {
                database.levelsUnlockedIds.remove(levelId)
            }
        } else {
            throw Err.WrongKey
        }
    }
    
    func nextLevel(of levelKey:LevelKey) -> LevelKey? {
        if stages.indices.contains(levelKey.stage) {
            if stages[levelKey.stage].levels.indices.contains(levelKey.level+1) {
                return LevelKey(stage:levelKey.stage, level:levelKey.level+1)
            } else if stages.indices.contains(levelKey.stage + 1)
                        ,stages[levelKey.stage + 1].levels.indices.contains(0)
            {
                return LevelKey(stage: levelKey.stage + 1, level: 0)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension GameReward {
    var caseId : Int {
        switch(self) {
        case .LevelCompleted: return 10
        case .NewBestScore: return 20
        case .NewImage: return 30
        case .NewLevelUnlocked: return 40
        case .NewStageUnlocked: return 50
        case .NewUnknownImage: return 31
        }
    }
    func sameCase(as other:GameReward) -> Bool {
        return self.caseId == other.caseId
    }
}
extension Array where Element == GameReward {
    func filter(onlyCases gameReward: GameReward) -> [GameReward] {
        self.filter { $0.sameCase(as: gameReward) }
    }
}
