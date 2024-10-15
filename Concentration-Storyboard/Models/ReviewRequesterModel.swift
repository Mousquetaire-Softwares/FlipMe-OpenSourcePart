//
//  ReviewRequesterModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 06/06/2024.
//

import Foundation

class ReviewRequesterModel {
    public static var Shared = ReviewRequesterModel()
    
    private init() {
        loadData()
    }
    
    internal func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    private(set) var numberOfLevelsPlayedSinceLastReviewRequest : Int = 0
    private(set) var numberOfReviewRequests : Int = 0

    private func loadData() {
        let defaults = userDefaults()
        
        self.numberOfLevelsPlayedSinceLastReviewRequest = (defaults.value(forKey: GameDatabase.DataKeys.NumberOfLevelsPlayedSinceLastReviewRequest) as? Int) ?? 0
        
        self.numberOfReviewRequests = (defaults.value(forKey: GameDatabase.DataKeys.NumberOfReviewRequests) as? Int) ?? 0
    }
    
    private func saveData() {
        let defaults = userDefaults()
        
        defaults.set(self.numberOfLevelsPlayedSinceLastReviewRequest
                     , forKey: GameDatabase.DataKeys.NumberOfLevelsPlayedSinceLastReviewRequest)
        defaults.set(self.numberOfReviewRequests
                     , forKey: GameDatabase.DataKeys.NumberOfReviewRequests)
    }
    
    
    func gameAchievement(finalLevelState levelState:LevelState
                         , finalScore score: GameScoreModelProtocol
                         , requestReviewLauncher : (()->()))
    {
        self.numberOfLevelsPlayedSinceLastReviewRequest += 1
        
        let nowIsAppropriateForReviewRequest = {
            !levelState.completed
            && score.rank.appropriateForRequestingReview
            && levelState.levelKey.appropriateForRequestingReview
            && self.numberOfLevelsPlayedSinceLastReviewRequest >= GameParameter.NumberOfLevelsToPlayBeforeRequest(previousReviewRequests: numberOfReviewRequests)
        }()
        
        if nowIsAppropriateForReviewRequest {
            requestReviewLauncher()
            self.numberOfReviewRequests += 1
            self.numberOfLevelsPlayedSinceLastReviewRequest = 0
        }
        self.saveData()
    }
}

extension ScoreRank {
    var appropriateForRequestingReview : Bool { self == .Three }
}

extension LevelKey {
    var appropriateForRequestingReview : Bool {
        return level >= 2 || (stage >= 1 && level >= 2)
    }
}

extension ReviewRequesterModel {
    struct GameParameter {
        static func NumberOfLevelsToPlayBeforeRequest(previousReviewRequests: Int) -> Int {
            switch(previousReviewRequests) {
            case 0: return 3
            case 1: return 20
            default: return 60
            }
        }
    }
}
