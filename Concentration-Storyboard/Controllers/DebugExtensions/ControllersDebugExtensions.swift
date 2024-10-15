//
//  ControllersDebugExtensions.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 06/05/2024.
//

import Foundation

#if DEBUG
extension GameModeChooserViewController {
    override var prefersStatusBarHidden: Bool { true }
}
extension LevelViewController {
    override var prefersStatusBarHidden: Bool { true }
}

#endif
