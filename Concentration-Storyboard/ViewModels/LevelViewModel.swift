//
//  LevelViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 08/02/2024.
//

import Foundation

protocol LevelViewModelProtocol {
    var key : LevelKey { get }
    var gameProcess : GameProcessViewModel { get }
    var delegate : GameProcessViewModelDelegate? { get set }
    var cardsByMatch : Int { get }
    var cardsToDeal : Int { get }
    var userCanAddCards : Bool { get }
    var staticOrientation : Bool { get }
    var state : LevelState { get }
    mutating func startNewGame()
    mutating func setGamePlaying(shuffleCardsLocationsIfGameWasDealing:Bool)
}


struct LevelViewModel : LevelViewModelProtocol {
    init(model: LevelModelProtocol, using deck:DeckModelProtocol) {
        self.state = model.state
        self.key = model.key
        self.deck = deck
        self.cardsByMatch = model.cardsByMatch
        self.cardsToDeal = model.cardsToDeal
        self.userCanAddCards = model.userCanDealCards
        self.playingMode = model.gamePlayingMode
        
        if case .DualImageMultiOrder = model.cardsType {
            staticOrientation = true
        } else {
            staticOrientation = false
        }
    }

    
//    private let model : LevelModelProtocol
    private var deck : DeckModelProtocol
    let key : LevelKey
    let cardsByMatch : Int
    let cardsToDeal : Int
    let userCanAddCards: Bool
    let staticOrientation : Bool
    var state : LevelState
    private let playingMode : GamePlayingMode
    
    private(set) var gameProcess : GameProcessViewModel = .NotInitialized
    
    weak var delegate : GameProcessViewModelDelegate? {
        didSet {
            switch(gameProcess) {
            case .NotInitialized:
                break
            case .Dealing(let dealer):
                dealer.delegate = delegate
            case .Playing(let playingEngine):
                playingEngine.delegate = delegate
            }
        }
    }
    
    private func createNewGametable() -> GametableViewModel {
        return GametableViewModel(cardsByMatch: cardsByMatch)
    }
    
    mutating func startNewGame() {
        deck.newDeal(renewingImages: true)
        let dealer = DealerViewModel(deck: deck
                                     , gametable: createNewGametable())
        dealer.delegate = delegate
        self.gameProcess = .Dealing(dealer)
    }
    
    
    mutating func setGamePlaying(shuffleCardsLocationsIfGameWasDealing shuffleCards:Bool = true)
    {
        switch(gameProcess) {
        case .NotInitialized:
            startNewGame()
            setGamePlaying(shuffleCardsLocationsIfGameWasDealing: shuffleCards)
        case .Dealing(let dealer):
            var gametable = dealer.gametable
            if shuffleCards {
                gametable.shuffleCardsLocations()
            }
            let playingEngine = createPlayingEngine(gametable:gametable)
            gameProcess = .Playing(playingEngine)
        case .Playing(_):
            break
        }
    }
    
    private func createPlayingEngine(gametable: GametableViewModelProtocol) -> PlayingEngineViewModelProtocol {
        switch(playingMode) {
        case .SinglePlayerTimeLimited(_):
            fallthrough
        case .SinglePlayer:
            let scoreEngine = ScoreEngineViewModel(numberOfCards: gametable.cards.count
                                                   , cardsByMatch: gametable.cardsByMatch)
            let playingEngine = SinglePlayingViewModel(gametable: gametable
                                                       , scoreEngine: scoreEngine)
            playingEngine.delegate = delegate
            return playingEngine
        case .MultiPlayer:
            let playingEngine = MultiPlayingViewModel(gametable: gametable
                                                      , players: Set<PlayerId>([0,1]))
            playingEngine.delegate = delegate
            return playingEngine
        }
    }
}


