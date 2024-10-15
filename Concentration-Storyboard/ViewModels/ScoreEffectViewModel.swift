//
//  ScoreEffectViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 22/03/2024.
//

import Foundation
import UIKit

enum ScoreEffectViewModel {
    case LuckyMatch(consecutiveMatches:Int)
    case Match(consecutiveMatches:Int)
    case ConsecutivesMatchesLost(previousMatches:Int)
    case BadMove
}

extension ScoreEffectViewModel {
    
    var particlesImages : [UIImage] {
        switch(self) {
        case .ConsecutivesMatchesLost(_):
            return ParticlesLibraryViewModel.Exclamations.UIImages
            
        case .LuckyMatch:
            return ParticlesLibraryViewModel.Rainbows.UIImages
            
        case .Match(let consecutiveMatches):
            var resultParts = [[UIImage]]()
            switch(consecutiveMatches) {
            case ...1:
                resultParts = [ ParticlesLibraryViewModel.Stars.Yellow.UIImages]
            case 2:
                resultParts = [ ParticlesLibraryViewModel.HappyFaces.Yellow.UIImages
                                , ParticlesLibraryViewModel.Stars.Yellow.UIImages]
            case 3:
                resultParts = [ ParticlesLibraryViewModel.HappyFaces.Yellow.UIImages
                                , ParticlesLibraryViewModel.Stars.Yellow.UIImages
                                , ParticlesLibraryViewModel.HappyFaces.Green.UIImages
                                , ParticlesLibraryViewModel.Stars.Green.UIImages ]
            case 4:
                resultParts = [ ParticlesLibraryViewModel.HappyFaces.Yellow.UIImages
                                , ParticlesLibraryViewModel.HappyFaces.Green.UIImages
                                , ParticlesLibraryViewModel.Stars.Green.UIImages
                                , ParticlesLibraryViewModel.HappyFaces.Pink.UIImages
                                , ParticlesLibraryViewModel.Stars.Pink.UIImages ]
            case 5:
                resultParts = [ ParticlesLibraryViewModel.HappyFaces.Green.UIImages
                                , ParticlesLibraryViewModel.HappyFaces.Pink.UIImages
                                , ParticlesLibraryViewModel.Stars.Pink.UIImages
                                , ParticlesLibraryViewModel.HappyFaces.Blue.UIImages
                                , ParticlesLibraryViewModel.Stars.Blue.UIImages ]
            case 6:
                resultParts = [ ParticlesLibraryViewModel.HappyFaces.Pink.UIImages
                                , ParticlesLibraryViewModel.HappyFaces.Blue.UIImages
                                , ParticlesLibraryViewModel.Stars.Blue.UIImages ]
            case 7...:
                resultParts = [ ParticlesLibraryViewModel.HappyFaces.Blue.UIImages
                                , ParticlesLibraryViewModel.Stars.Blue.UIImages ]
            default:
                break
            }
            return resultParts.flatMap{$0}
            
        case .BadMove:
            return ParticlesLibraryViewModel.BadFaces.UIImages
        }
    }
    var particlesQuantity : Int {
        switch(self) {
        case .LuckyMatch(let consecutiveMatches): 
            fallthrough
        case .Match(let consecutiveMatches):
            return 8 + (consecutiveMatches < 2 ? 0 : Int((pow(Float(consecutiveMatches),1.6) * 2)))
        case .ConsecutivesMatchesLost(let previousMatches):
            return 4 + (previousMatches < 2 ? 0 : Int((pow(Float(previousMatches),1.6) * 1)))
        case .BadMove:
            return 5
        }
    }
    var animationDuration : TimeInterval {
        switch(self) {
        case .LuckyMatch(let consecutiveMatches):
            fallthrough
        case .Match(let consecutiveMatches):
            if consecutiveMatches < 2 {
                return UIParameter.SuccessBaseDuration
            } else {
                return UIParameter.SuccessBaseDuration + (
                    UIParameter.SuccessAdditionalDuration * (Double(consecutiveMatches) / Double(consecutiveMatches + 2))
                    )
            }
        case .ConsecutivesMatchesLost:
            return UIParameter.NoSuccessBaseDuration
        case .BadMove:
            return UIParameter.NoSuccessBaseDuration
        }
    }
}

extension ScoreEffectViewModel {
    struct UIParameter {
        static let SuccessBaseDuration : TimeInterval = 1
        static let SuccessAdditionalDuration : TimeInterval = 1
        static let NoSuccessBaseDuration : TimeInterval = 1
    }
}

