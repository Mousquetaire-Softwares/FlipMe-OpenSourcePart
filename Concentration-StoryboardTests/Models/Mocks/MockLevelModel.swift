import Foundation
@testable import FlipMe_OpenSource

struct MockLevelModel : LevelModelProtocol {

    var key: LevelKey
    
    var id: String = TestsValues.String
    
    var unlocked: Bool
    
    var cardsToDeal: Int
    
    var cardsByMatch: Int
    
    var userCanDealCards: Bool
    
    var cardsType: CardType
    
    var gamePlayingMode: GamePlayingMode
    
    private(set) var privateState : LevelState?
    var state: LevelState {
        get { return privateState ?? LevelState(levelKeyForTests: self.key, unlocked: self.unlocked) }
        set { privateState = newValue }
    }
    
    mutating func setState(_ value: LevelState) throws {
        state = value
    }
    

}
