//
//  UnitTestingAppDelegate.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 20/11/2023.
//

import UIKit

//@main
@objc(UnitTestingAppDelegate)
class UnitTestingAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("<<< Launching UnitTestingAppDelegate (0)")
        return true
    }

//    // MARK: UISceneSession Lifecycle
//    var restrictRotation:UIInterfaceOrientationMask = .all
//
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
//    {
//        print("<<< Launching UnitTestingAppDelegate (1)")
//        return self.restrictRotation
//    }

}
