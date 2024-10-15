//
//  EndOfGameViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 29/02/2024.
//

import Foundation

protocol EndOfGameViewModelProtocol {
    var score : GameScoreModelProtocol { get }
    var levelStates : (previous:LevelState, new:LevelState) { get }
    var nextLevelStates : (previous:LevelState, new:LevelState)? { get }
    var rewards : [GameReward] { get }
    var potentialRewards : [GameReward] { get }
    
    var newLevelsUnlocked : [LevelKey] { get }
    var newImageUnlocked : ImageName? { get  }
}

struct EndOfGameViewModel : EndOfGameViewModelProtocol {
    internal init?(of levelKey:LevelKey, withFinalScore score: GameScoreModelProtocol, using givenLevelsLibrary:LevelsLibraryModel) {
        var levelsLibrary = givenLevelsLibrary
        do {
            self.potentialRewards = levelsLibrary.potentialReward(completing: levelKey)
            
            let levelPreviousState = try levelsLibrary[levelKey].state
            
            // get next level previous state if exists
            let nextLevelKey = levelsLibrary.nextLevel(of: levelKey)
            let nextLevelPreviousState : LevelState?
            if let nextLevelKey {
                nextLevelPreviousState = try levelsLibrary[nextLevelKey].state
            } else {
                nextLevelPreviousState = nil
            }
            
            // now perform achievement in library and get the new state
            let rewards = levelsLibrary.gameAchievement(of: levelKey
                                                        , withFinalScore: score)
            let levelNewState = try levelsLibrary[levelKey].state
            self.levelStates = (previous: levelPreviousState, new: levelNewState)
            
            // get next level new state if exists
            if let nextLevelKey, let nextLevelPreviousState {
                self.nextLevelStates = (previous: nextLevelPreviousState, try levelsLibrary[nextLevelKey].state)
            } else {
                self.nextLevelStates = nil
            }
            
            // others properties
            self.levelKey = levelKey
            self.score = score
            self.rewards = rewards
            
            self.newlevelsLibrary = levelsLibrary
        } catch {
            return nil
        }
    }
    
    internal let newlevelsLibrary : LevelsLibraryModel
            
    
    
    let rewards : [GameReward]
    let levelKey : LevelKey
    let score : GameScoreModelProtocol
    let levelStates : (previous:LevelState, new:LevelState)
    let nextLevelStates : (previous:LevelState, new:LevelState)?

    let potentialRewards : [GameReward]
    
    var newLevelsUnlocked : [LevelKey] {
        rewards
            .compactMap{ if case .NewLevelUnlocked(let levelKey) = $0 { return levelKey } else { return nil } }
    }

    var newImageUnlocked: ImageName? {
        rewards
            .compactMap{ if case .NewImage(let image) = $0 { return image } else { return nil } }
            .first
    }
    

}
