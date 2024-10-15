//
//  main.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 20/11/2023.
//

import Foundation
import UIKit

let appDelegateClass: AnyClass =
NSClassFromString("UnitTestingAppDelegate") ?? AppDelegate.self

UIApplicationMain(CommandLine.argc
                  , CommandLine.unsafeArgv
                  , nil
                  , NSStringFromClass(appDelegateClass))
