import Foundation


enum GamePlayingMode : Equatable, Hashable {
    case SinglePlayer
    case SinglePlayerTimeLimited(limitBetweenCards:TimeInterval)
    case MultiPlayer
}

enum CardType : Equatable, Hashable {
    case SingleImage
    case SingleImageMultiColors(colorsCount:Int)
    case DualImage
    case DualImageMultiOrder
    
    var imagesCategory : ImageCategory {
        get {
            switch(self) {
            case .DualImage: return .ImageForCardsWithDoubleImages
            case .DualImageMultiOrder: return .ImageForCardsWithDoubleImages
            case .SingleImage: return .AnyImage
            case .SingleImageMultiColors(_): return .AnyImage
            }
        }
    }
}


struct LevelState {
    fileprivate init(levelKey: LevelKey, unlocked: Bool) {
        self.levelKey = levelKey
        self.unlocked = unlocked
    }
    let levelKey: LevelKey
    var unlocked : Bool
    var points : Points = StartingPointsDefaultValue
    var bestScore : GameScoreModelProtocol? = nil
    let neededPointsToComplete : Points = NeededPointsToCompleteDefaultValue
    var completed : Bool { points >= neededPointsToComplete }
#if DEBUG
    init(levelKeyForTests: LevelKey, unlocked: Bool) {
        self.levelKey = levelKeyForTests
        self.unlocked = unlocked
    }
#endif
}
extension LevelState {
    // The number of points doesn't match the score
    // 109 is the maximum value to allow the completion of a level with a score of 100/100
    static let NeededPointsToCompleteDefaultValue : Points = 109
    static let StartingPointsDefaultValue : Points = 0
}


protocol LevelModelProtocol {
    var key: LevelKey { get }
    var id : String { get }
    var state: LevelState { get }
    mutating func setState(_:LevelState) throws
    var cardsToDeal : Int { get }
    var cardsByMatch: Int { get }
    var userCanDealCards: Bool { get }
    var cardsType : CardType { get }
    var gamePlayingMode : GamePlayingMode { get }
}

struct LevelModel : LevelModelProtocol {
    enum Err : Error { case LevelStateKeyMismatch }
    
    init(key: LevelKey
         , id: InvariantId
         , unlocked: Bool
         , cardsToDeal: Int
         , cardsByMatch: Int
         , userCanDealCards: Bool
         , cardsType: CardType
         , gamePlayingMode: GamePlayingMode)
    {
        self.key = key
        self.id = id
        self.state = LevelState(levelKey: key, unlocked: unlocked)
        self.cardsToDeal = cardsToDeal
        self.cardsByMatch = cardsByMatch
        self.userCanDealCards = userCanDealCards
        self.cardsType = cardsType
        self.gamePlayingMode = gamePlayingMode
    }
    
    let key: LevelKey
    let id : InvariantId

    // state of the level, depending on the user achievements
    private(set) var state: LevelState
    mutating func setState(_ newState:LevelState) throws {
        if newState.levelKey != self.key {
            throw Err.LevelStateKeyMismatch
        }
        state = newState
    }

    // game characteristics
    let cardsToDeal : Int
    let cardsByMatch: Int
    let userCanDealCards: Bool
    let cardsType : CardType
    let gamePlayingMode : GamePlayingMode

    
}
