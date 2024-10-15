//
//  MockDealerViewModel.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 08/02/2024.
//

import Foundation
@testable import Concentration_Storyboard

class MockDealerViewModelEmpty : DealerViewModelProtocol {
    var gametable: GametableViewModelProtocol = MockGametableViewModelEmpty()
    
    func addCardsInGametable(expandingDirection: GametableExpandingDirection?) throws -> [CardViewModel.KeyValue] {
        []
    }
    
    var delegate: DealerViewModelDelegate?
}
