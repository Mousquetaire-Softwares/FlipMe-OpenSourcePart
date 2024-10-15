//
//  AppDelegateExtension.swift
//  Concentration-StoryboardDemos
//
//  Created by Steven Morin on 10/05/2024.
//

import Foundation


#if DEBUG
extension AppDelegate {
    enum DemoConfiguration {
        case Normal
        case DemoIpad11ProLandscape(forScreenRatio:CGFloat) // for recording videos on ipad 11 pro but with a different - and lower - screen ratio (for App Preview on others ipads)
        case DemoIphone13MiniPortrait(forScreenRatio:CGFloat, removeSafeAreaOffset:Bool) // for recording videos on ipad 13 mini but with a different - and lower - screen ratio (for App Preview on others iphones)
        
        var widthOffset : CGFloat {
            switch(self) {
            case .Normal:
                return 0
            case .DemoIpad11ProLandscape(let targetScreenRatio):
                let realDeviceScreenSize = CGSize(width: 1194, height: 834)
                let targetScreenWidth : CGFloat = targetScreenRatio * realDeviceScreenSize.height
                return (realDeviceScreenSize.width - targetScreenWidth) / 2
            case .DemoIphone13MiniPortrait:
                return 0
            }
        }        
        var topOffset : CGFloat {
            switch(self) {
            case .Normal:
                return 0
            case .DemoIpad11ProLandscape:
                return 0
            case .DemoIphone13MiniPortrait(let targetScreenRatio, let removeSafeAreaOffset):
                let safeAreaSize = CGRect(x: 0, y: 50, width: 375, height: 728)
                let realDeviceScreenSize = CGSize(width: 375, height: 812)
                let targetScreenHeight : CGFloat = targetScreenRatio * realDeviceScreenSize.width
                let heightOffset = (realDeviceScreenSize.height - targetScreenHeight) / 2
                
                if removeSafeAreaOffset {
                    return heightOffset - safeAreaSize.minY
                } else {
                    return heightOffset
                }
            }
        }
        var bottomOffset : CGFloat {
            switch(self) {
            case .Normal:
                return 0
            case .DemoIpad11ProLandscape:
                return 0
            case .DemoIphone13MiniPortrait(let targetScreenRatio, let removeSafeAreaOffset):
                let safeAreaSize = CGRect(x: 0, y: 50, width: 375, height: 728)
                let realDeviceScreenSize = CGSize(width: 375, height: 812)
                let targetScreenHeight : CGFloat = targetScreenRatio * realDeviceScreenSize.width
                let heightOffset = (realDeviceScreenSize.height - targetScreenHeight) / 2
                
                if removeSafeAreaOffset {
                    return heightOffset - (realDeviceScreenSize.height - safeAreaSize.maxY)
                } else {
                    return heightOffset
                }
            }
        }
    }
//    static let Configuration = DemoConfiguration.DemoIpad11ProLandscape(forScreenRatio: 4/3)
    static let Configuration = DemoConfiguration.DemoIphone13MiniPortrait(forScreenRatio: 16/9, removeSafeAreaOffset: true)
}
#endif
