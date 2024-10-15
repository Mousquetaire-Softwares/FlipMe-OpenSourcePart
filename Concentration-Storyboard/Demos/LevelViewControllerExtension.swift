//
//  LevelViewControllerExtension.swift
//  Concentration-StoryboardDemos
//
//  Created by Steven Morin on 10/05/2024.
//

import Foundation


#if DEBUG
extension LevelViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let widthOffset = AppDelegate.Configuration.widthOffset
        let topOffset = AppDelegate.Configuration.topOffset
        let bottomOffset = AppDelegate.Configuration.bottomOffset
        
        switch(AppDelegate.Configuration) {
            
        case .DemoIpad11ProLandscape:
            if self.masterStackLeftConstraint.constant < widthOffset {
                self.masterStackLeftConstraint.constant += widthOffset
            }
            if self.masterStackRightConstraint.constant < widthOffset {
                self.masterStackRightConstraint.constant += widthOffset
            }
            if self.masterButtonRightConstraint.constant < widthOffset {
                self.masterButtonRightConstraint.constant += widthOffset
            }
        case .DemoIphone13MiniPortrait:
            if self.masterButtonTopConstraint.constant < topOffset {
                self.masterButtonTopConstraint.constant += topOffset
            }
            if self.levelMasterStackBottomConstraint.constant < bottomOffset {
                self.levelMasterStackBottomConstraint.constant += bottomOffset
            }
        default:
            break
        }
    }
}
#endif
