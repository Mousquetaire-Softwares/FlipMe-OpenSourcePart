//
//  GameViewModel.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 09/02/2024.
//

import Foundation

protocol GameProcessViewModelDelegate : DealerViewModelDelegate, PlayingEngineViewModelDelegate {
}

enum GameProcessViewModel {
    case NotInitialized
    case Dealing(DealerViewModelProtocol)
    case Playing(PlayingEngineViewModelProtocol)
    
    var gametable : GametableViewModelProtocol? {
        switch(self) {
        case .NotInitialized : return nil
        case .Dealing(let dealer) : return dealer.gametable
        case .Playing(let playing) : return playing.gametable
        }
    }
}
