//
//  SuccessEffectViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 31/01/2024.
//

import UIKit



protocol VfxViewControllerProtocol {
    func startAnimation(doNotDismissWhenFinished:Bool)
}
typealias VfxViewController = UIViewController & VfxViewControllerProtocol

