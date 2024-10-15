//
//  DeviceOrientation.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 13/03/2024.
//

import Foundation
import UIKit


extension UIInterfaceOrientation {
    enum Change {
        case TurnedClockwise
        case TurnedCounterClockwise
        case HalfTurn
        case None
    }
    func changeHappened(since previousOrientation:UIInterfaceOrientation) -> Change {
        func quarterNum(of value:UIInterfaceOrientation) -> Int? {
            switch(value) {
            // Notice that UIDeviceOrientation.landscapeRight is assigned to UIInterfaceOrientation.landscapeLeft and UIDeviceOrientation.landscapeLeft is assigned to UIInterfaceOrientation.landscapeRight. The reason for this is that rotating the device requires rotating the content in the opposite direction.
            // Reference : https://developer.apple.com/documentation/uikit/uiinterfaceorientation
            case .landscapeLeft: return 0
            case .landscapeRight: return 2
            case .portrait: return 1
            case .portraitUpsideDown: return 3
            case .unknown: return nil
            @unknown default:
                return nil
            }
        }
        let currentQuarterNum = quarterNum(of: self)
        let previousQuarterNum = quarterNum(of: previousOrientation)
        
        if let currentQuarterNum, let previousQuarterNum {
            if (currentQuarterNum + previousQuarterNum).isMultiple(of: 2) {
                if currentQuarterNum == previousQuarterNum {
                    return .None
                } else {
                    return .HalfTurn
                }
            } else {
                if (((currentQuarterNum - previousQuarterNum) + 4) % 4) == 1 {
                    return .TurnedCounterClockwise
                } else {
                    return .TurnedClockwise
                }
            }
        } else {
            return .None
        }
    }
    
    // gets the current interface orientation
    static var current : UIInterfaceOrientation {
        let interfaceOrientation: UIInterfaceOrientation?
        if #available(iOS 15, *) {
            interfaceOrientation = UIApplication.shared.connectedScenes
            // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
            // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.interfaceOrientation
        } else {
            interfaceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        }
        return interfaceOrientation ?? .unknown
    }
}

