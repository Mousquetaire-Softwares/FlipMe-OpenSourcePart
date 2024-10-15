//
//  Score.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 25/01/2024.
//

import Foundation

enum ScoreRank { case Zero, One, Two, Three, Four }
typealias Score = Float
typealias Points = Float

protocol GameScoreModelProtocol {
    var score : Score { get }
    var points : Points { get }
    var rank : ScoreRank { get }
}

extension GameScoreModelProtocol {
    var rank : ScoreRank {
        if score > 0.99 { return .Four }
        else if score > 0.90 { return .Three }
        else if score > 0.70 { return .Two }
        else if score > 0.50 { return .One }
        else { return .Zero }
    }
}

struct GameBestScoreModel : GameScoreModelProtocol {
    var score : Score
    let points : Points = 0
}

struct GameScoreModel : GameScoreModelProtocol {
    let numberOfCards : Int
    let cardsByMatch : Int
    var badMoves : Int = 0
    var seriesOfConsecutiveMatches : [Int] = []
    
    var score : Score {
        if badMoves == 0 {
            return 1
        } else {
            // some magic is happening here in the real version, instead of this
            let bonusCalculator3 = Float(seriesOfConsecutiveMatches.count)
            
            let penalty : Float = Float(badMoves) / bonusCalculator3
            
            let iv1 : Float = 1 + (penalty.zeroIfNegative / Float(numberOfCards))
            
            let iv2 : Float = 1 / iv1

            return iv2 > 0.99 ? 0.99 : iv2
        }
    }
    
    var points : Points {
        var result = pow(2.71828,((score-0.5) * 8))
        if badMoves == 0 {
            result *= 2
        }
        return result
    }
}
