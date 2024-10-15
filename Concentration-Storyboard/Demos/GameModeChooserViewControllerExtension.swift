//
//  GameModeChooserViewControllerExtension.swift
//  Concentration-StoryboardDemos
//
//  Created by Steven Morin on 11/05/2024.
//

import Foundation

#if DEBUG
extension GameModeChooserViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let widthOffset = AppDelegate.Configuration.widthOffset
        let topOffset = AppDelegate.Configuration.topOffset
        let bottomOffset = AppDelegate.Configuration.bottomOffset
        
        switch(AppDelegate.Configuration) {
        case .DemoIpad11ProLandscape:
            if self.safeboxButtonRightConstraint.constant < widthOffset {
                self.safeboxButtonRightConstraint.constant += widthOffset
            }
            if self.helpButtonLeftConstraint.constant < widthOffset {
                self.helpButtonLeftConstraint.constant += widthOffset
            }
        case .DemoIphone13MiniPortrait:
            if self.titleTopConstraint.constant < topOffset {
                self.titleTopConstraint.constant += topOffset
            }
            if self.safeboxButtonBottomConstraint.constant < bottomOffset {
                self.safeboxButtonBottomConstraint.constant += bottomOffset
            }
        default:
            break
        }
    }
}
#endif
