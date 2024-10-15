//
//  VfxBouncingViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 05/02/2024.
//

import Foundation
import UIKit

class VfxBouncingViewController: VfxViewController {
    
    init(viewToMakeBounce view:UIView
         , duration:TimeInterval
         , delay:TimeInterval
         , completion: ((Bool)->())? = nil)
    {
        self.viewToMove = view
        self.completion = completion
        self.duration = duration
        self.delay = delay
        super.init(nibName: nil, bundle: nil)
        self.view.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not valid use of \(Self.description())")
    }
    
    private weak var viewToMove:UIView?
    private let completion : ((Bool)->())?
    private let duration:TimeInterval
    private let delay: TimeInterval
    
    
    func startAnimation(doNotDismissWhenFinished: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIView.animate(withDuration: self.duration / 2
                           ,delay: self.delay
                           ,usingSpringWithDamping: 0.01
                           ,initialSpringVelocity: 0
                           ,animations: {
                if let viewToMove = self.viewToMove {
                    viewToMove.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            }
                           ,completion: {
                _ in
                UIView.animate(withDuration: (self.duration)/2
                               ,delay: 0
                               ,usingSpringWithDamping: 1
                               ,initialSpringVelocity: 0
                               ,animations: {
                    if let viewToMove = self.viewToMove {
                        viewToMove.transform = .identity
                    }
                }
                               ,completion: {
                    [weak self] finished in
                    self?.completion?(finished)
                    
                    if !doNotDismissWhenFinished {
                        self?.view.removeFromSuperview()
                        self?.removeFromParent()
                    }
                }
                )
            }
            )
        }
        
    }
    
}

