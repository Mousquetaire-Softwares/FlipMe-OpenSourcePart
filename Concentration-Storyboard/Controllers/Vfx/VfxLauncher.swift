//
//  MultiCardVfxSyncController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 29/01/2024.
//

import Foundation
import UIKit

protocol VfxLauncherProtocol : AnyObject {
    func set(trigger:Int, value:Bool)
}

class VfxLauncher : VfxLauncherProtocol {
    
    init(parent:UIViewController
         , triggers:[Int]
         , targets:[UIViewController]
         , vfxBuildersFromTarget:@escaping (UIViewController) -> [VfxViewController]
         , vfxCaller: ((VfxViewController) -> ())? = nil)
    {
        self.parent = parent
        self.triggers = triggers
        self.vfxBuildersFromTarget = vfxBuildersFromTarget
        self.vfxCaller = vfxCaller
        self.targets = targets
        instantiateVfxIfAllTargetsReady()
    }
    
    private weak var parent : UIViewController?
    
    private var triggers : [Int]
    private lazy var triggersValues : [Bool] = Array(repeating: false, count: triggers.count)
    
    private var vfxBuildersFromTarget: (UIViewController) -> [VfxViewController]
    private var vfxCaller: ((VfxViewController) -> ())?
    @WeakArray private var targets = [UIViewController]()
    
    func set(trigger:Int, value:Bool) {
        if let index = self.triggers.firstIndex(of: trigger) {
            triggersValues[index] = value
            
            if instantiateVfxHasBeenDone == false {
                instantiateVfxIfAllTargetsReady()
            }
        }
    }
    
    private var instantiateVfxHasBeenDone = false
    
    private func instantiateVfxIfAllTargetsReady() {
        if triggersValues.filter({ $0 == false }).isEmpty {
            instantiateVfx()
        }
    }
    
    private func instantiateVfx() {
        instantiateVfxHasBeenDone = true
        
        targets.forEach{
            targetVC in
            if let parent
                , let targetVC
                , let targetView = targetVC.view
            {
                let vfxViewControllers = vfxBuildersFromTarget(targetVC)
                vfxViewControllers.forEach{
                    vfxVC in
                    vfxVC.view.isUserInteractionEnabled = false
                    
                    parent.addChild(vfxVC)
                    parent.view.addSubview(vfxVC.view)
                    vfxVC.view.frame = parent.view.convert(targetView.bounds, from: targetView)
                    vfxVC.didMove(toParent: parent)
                    
                    vfxCaller?(vfxVC)
                }
            }
        }
    }
    
}
