//
//  LevelsLibraryViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 09/02/2024.
//

import Foundation
import CoreGraphics

protocol LevelsLibraryViewModelProtocol : AnyObject {
    func processEndOfGame(of:LevelKey, withFinalScore: GameScoreModelProtocol) -> EndOfGameViewModel?
}

class LevelsLibraryViewModel : LevelsLibraryViewModelProtocol {
    
    private let imagesLibrary = ImagesLibraryModel.Shared
    private var levelsLibrary = LevelsLibraryModel.Shared
    
    
    private(set) lazy var stages : [StageKey:StageViewModelProtocol] = {
        var sharedPicker = ImagesLibrarySharedPickerModel(using: self.imagesLibrary)
        
        let stagesKeysValues = levelsLibrary.stages.map {
            var stage = StageViewModel(model: $0, usingForCardsExamples: sharedPicker)
            
            return ($0.key
                    , stage)
        }
        
        return [StageKey:StageViewModelProtocol](stagesKeysValues
                                                 , uniquingKeysWith: { v1,v2 in v1 })
    }()
    
    
    private(set) lazy var levels : [LevelKey:LevelViewModel] = {
        let sharedPicker = ImagesLibrarySharedPickerModel(using: self.imagesLibrary)
        
        let levelsKeysValues = levelsLibrary
            .stages
            .flatMap { $0.levels }
            .map
        {
            let deck = DeckModelBuilder.CreateDeck(for: $0.cardsType
                                                   , using: sharedPicker)
            return ($0.key
                    , LevelViewModel(model: $0, using: deck))
        }
        
        return [LevelKey:LevelViewModel](levelsKeysValues
                                         , uniquingKeysWith: {v1,v2 in v1 })
    }()

    private func updateLevelStateFromLibrary(of levelKey:LevelKey) {
        if levels.keys.contains(levelKey) {
            levels[levelKey]!.state = levelsLibrary.stages[levelKey.stage].levels[levelKey.level].state
        }
    }
    
    
    func processEndOfGame(of levelKey:LevelKey, withFinalScore score: GameScoreModelProtocol) -> EndOfGameViewModel? {
        // Trying to create the EndOfGame VM object. If it succeeds, we must update SELF
        if let endOfGame = EndOfGameViewModel(of: levelKey, withFinalScore: score, using: self.levelsLibrary) {
            self.levelsLibrary = endOfGame.newlevelsLibrary
            // local update of level
            updateLevelStateFromLibrary(of:levelKey)
            
            // local update of next level, if any
            if let (_, nextLevelNewState) = endOfGame.nextLevelStates {
                updateLevelStateFromLibrary(of: nextLevelNewState.levelKey)
            }
            
            // local update of other updated levels (looking in rewards)
            let levelsUnlockedKeys = endOfGame.rewards.compactMap{
                switch($0) {
                case .NewLevelUnlocked(let levelKey): return levelKey
                default: return nil
                }
            }
            levelsUnlockedKeys.forEach{ updateLevelStateFromLibrary(of: $0) }
            
            return endOfGame
        } else {
            return nil
        }
    }


}


