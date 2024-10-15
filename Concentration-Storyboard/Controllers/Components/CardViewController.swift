//
//  CardViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 11/01/2024.
//

import UIKit

protocol CardViewControllerProtocol : AnyObject {
    var isVisible:Bool { get set }
    var isFaceUp:Bool { get }
    var viewModel : CardViewModel.KeyValue? { get set }
    var vfxLauncherWhenNotAnimated : VfxLauncherProtocol? { get set }
    func rotate(clockwise:Bool)
}

typealias CardViewController = UIViewController & CardViewControllerProtocol
