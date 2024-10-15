//
//  VfxMovingViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 05/02/2024.
//

import Foundation
import UIKit

/// Will modify a given view to look like a targetView.
/// Result will be for the given view to move and change size to match the targetView, with animation or not.
/// This can be done using two very different methods : by transform (applying a transform matrix on the view) or by setting new constraints.
class VfxMovingViewController: VfxViewController {
    enum Mode {
        case ByTransform
        case ByNewConstraints(RatioOption)
        
        enum RatioOption {
            case DoNotKeepRatio
            case KeepRatio(SizeConstraints, VerticalAlignment, HorizontalAlignment)
            
            enum SizeConstraints { case SmallerThanTarget, BiggerThanTarget }
            enum VerticalAlignment { case Top, Bottom } // not implemented yet : , Middle }
            enum HorizontalAlignment { case Right, Center } // not implemented yet : , Left }
        }
    }
    
    init(view:UIView
         , targetView:UIView
         , mode: Mode
         , duration:TimeInterval
         , delay:TimeInterval
         , completion: ((Bool)->())? = nil)
    {
        self.mode = mode
        self.viewToMove = view
        self.targetView = targetView
        self.completion = completion
        self.duration = duration
        self.delay = delay
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }

    
    private func commonInit() {
        self.view.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not valid use of \(Self.description())")
    }
    

    private let mode : Mode
    private weak var viewToMove:UIView?
    private weak var targetView:UIView?
    private let completion : ((Bool)->())?
    private let duration:TimeInterval
    private let delay: TimeInterval
    
    
    func startAnimation(doNotDismissWhenFinished: Bool = false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [self] in
            
            var newConstraints = [NSLayoutConstraint]()
            if let viewToMove, let targetView {
                if case .ByNewConstraints(let option) = mode {
                    removeRatioConstraints(of : viewToMove)
                    viewToMove.deactivateAllSuperviewsConstraints()
                    newConstraints = setNewConstraints(forView: viewToMove
                                                       , toLookLike: targetView
                                                       , ratioOption: option
                                                       , keepInitialApparenceWithConstraintsConstants: true)
                    viewToMove.superview?.layoutIfNeeded()
                }
            }
            
            UIView.animate(withDuration: self.duration
                           ,delay: self.delay
                           ,animations: { 
                [self] in
                guard let viewToMove, let targetView else { return }
                    
                switch (mode) {
                case .ByNewConstraints(_):
                    newConstraints.forEach{ $0.constant = 0 }
                    viewToMove.superview?.layoutIfNeeded()
                case .ByTransform:
                    viewToMove.transform = getTransform(forView: viewToMove, toLookLike: targetView)
                }
            }
                           ,completion: {
                finished in
                self.completion?(finished)
                if !doNotDismissWhenFinished {
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                }
            }
            )
        }

    }

    private func removeRatioConstraints(of view:UIView) {
            let constraints = view.constraints.filter({
                ($0.firstAttribute == .width && $0.secondAttribute == .height) || ($0.firstAttribute == .height && $0.secondAttribute == .width)
            })
            
            NSLayoutConstraint.deactivate(constraints)
    }
    
    
    func setNewConstraints(forView viewToTransform:UIView
                           , toLookLike viewToLookLike: UIView
                           , ratioOption: Mode.RatioOption
                           , keepInitialApparenceWithConstraintsConstants: Bool) -> [NSLayoutConstraint]
    {
        struct ContraintsConstants {
            var width, height, midX, minX, maxX, midY, minY, maxY : CGFloat
        }
        var contraintsConstants = ContraintsConstants(width: 0, height: 0, midX: 0, minX: 0, maxX: 0, midY: 0, minY: 0, maxY: 0)
        
        if keepInitialApparenceWithConstraintsConstants == true
            , let viewToTransformSuperview = viewToTransform.superview
            , let viewToLookLikeSuperview = viewToLookLike.superview
        {
            let frameToGet = viewToTransformSuperview.convert(viewToTransform.frame, to: nil)
            let realFrame = viewToLookLikeSuperview.convert(viewToLookLike.frame, to: nil)
         
            contraintsConstants.height = frameToGet.height - realFrame.height
            contraintsConstants.width = frameToGet.width - realFrame.width
            contraintsConstants.midX = frameToGet.midX - realFrame.midX
            contraintsConstants.minX = frameToGet.minX - realFrame.minX
            contraintsConstants.maxX = frameToGet.maxX - realFrame.maxX
            contraintsConstants.midY = frameToGet.midY - realFrame.midY
            contraintsConstants.minY = frameToGet.minY - realFrame.minY
            contraintsConstants.maxY = frameToGet.maxY - realFrame.maxY
        }
        
        let alignmentContraints : [NSLayoutConstraint]

        switch(ratioOption) {
        case .DoNotKeepRatio:
            alignmentContraints = [
                NSLayoutConstraint(item: viewToTransform
                                   , attribute: .centerX
                                   , relatedBy: .equal
                                   , toItem: viewToLookLike
                                   , attribute: .centerX
                                   , multiplier: 1
                                   , constant: contraintsConstants.midX),
                NSLayoutConstraint(item: viewToTransform
                                   , attribute: .centerY
                                   , relatedBy: .equal
                                   , toItem: viewToLookLike
                                   , attribute: .centerY
                                   , multiplier: 1
                                   , constant: contraintsConstants.midY)
            ]
        case .KeepRatio(_, let verticalAlignment, let horizontalAlignment):
            alignmentContraints = {
                let constraintX : NSLayoutConstraint
                switch(horizontalAlignment) {
                case .Right:
                    constraintX = NSLayoutConstraint(item: viewToTransform
                                                     , attribute: .right
                                                     , relatedBy: .equal
                                                     , toItem: viewToLookLike
                                                     , attribute: .right
                                                     , multiplier: 1
                                                     , constant: contraintsConstants.maxX)
                case .Center:
                    constraintX = NSLayoutConstraint(item: viewToTransform
                                                     , attribute: .centerX
                                                     , relatedBy: .equal
                                                     , toItem: viewToLookLike
                                                     , attribute: .centerX
                                                     , multiplier: 1
                                                     , constant: contraintsConstants.midX)
                }
                
                let constraintY : NSLayoutConstraint
                switch(verticalAlignment) {
                case .Top:
                    constraintY = NSLayoutConstraint(item: viewToTransform
                                                     , attribute: .top
                                                     , relatedBy: .equal
                                                     , toItem: viewToLookLike
                                                     , attribute: .top
                                                     , multiplier: 1
                                                     , constant: contraintsConstants.minY)
                case .Bottom:
                    constraintY = NSLayoutConstraint(item: viewToTransform
                                                     , attribute: .bottom
                                                     , relatedBy: .equal
                                                     , toItem: viewToLookLike
                                                     , attribute: .bottom
                                                     , multiplier: 1
                                                     , constant: contraintsConstants.maxY)
                }
                
                return [constraintX,constraintY]
            }()
        }
        
        let sizeConstraintsRequired : [NSLayoutConstraint]
        let currentWidthToHeight = viewToTransform.bounds.width / viewToTransform.bounds.height
        let constraintToKeepRatio = NSLayoutConstraint(item: viewToTransform
                                                       , attribute: .width
                                                       , relatedBy: .equal
                                                       , toItem: viewToTransform
                                                       , attribute: .height
                                                       , multiplier: currentWidthToHeight
                                                       , constant: 0)
        switch(ratioOption) {
        case .DoNotKeepRatio:
            sizeConstraintsRequired =  [
                viewToTransform.widthAnchor.constraint(equalTo: viewToLookLike.widthAnchor, constant: contraintsConstants.width)
                ,viewToTransform.heightAnchor.constraint(equalTo: viewToLookLike.heightAnchor, constant: contraintsConstants.height)
            ]
        case .KeepRatio(let sizeConstraints,_,_):
            switch(sizeConstraints) {
            case .SmallerThanTarget:
                sizeConstraintsRequired = [
                    constraintToKeepRatio
                    , NSLayoutConstraint(item: viewToTransform
                                         , attribute: .width
                                         , relatedBy: .lessThanOrEqual
                                         , toItem: viewToLookLike
                                         , attribute: .width
                                         , multiplier: 1
                                         , constant: contraintsConstants.width)
                    , NSLayoutConstraint(item: viewToTransform
                                         , attribute: .height
                                         , relatedBy: .lessThanOrEqual
                                         , toItem: viewToLookLike
                                         , attribute: .height
                                         , multiplier: 1
                                         , constant: contraintsConstants.height)
                ]
            case .BiggerThanTarget:
                sizeConstraintsRequired = [
                    constraintToKeepRatio
                    , NSLayoutConstraint(item: viewToTransform
                                         , attribute: .width
                                         , relatedBy: .greaterThanOrEqual
                                         , toItem: viewToLookLike
                                         , attribute: .width
                                         , multiplier: 1
                                         , constant: contraintsConstants.width)
                    , NSLayoutConstraint(item: viewToTransform
                                         , attribute: .height
                                         , relatedBy: .greaterThanOrEqual
                                         , toItem: viewToLookLike
                                         , attribute: .height
                                         , multiplier: 1
                                         , constant: contraintsConstants.height)
                ]
            }
        }

        
        let sizeConstraintsNotRequired : [NSLayoutConstraint]
        switch(ratioOption) {
        case .DoNotKeepRatio:
            sizeConstraintsNotRequired =  []
        case .KeepRatio(let sizeConstraints,_,_):
            switch(sizeConstraints) {
            case .SmallerThanTarget, .BiggerThanTarget:
                sizeConstraintsNotRequired = [NSLayoutConstraint.Attribute.width, .height].map{
                    NSLayoutConstraint(item: viewToTransform
                                       , attribute: $0
                                       , relatedBy: .equal
                                       , toItem: viewToLookLike
                                       , attribute: $0
                                       , multiplier: 1
                                       , constant: 0)
                }
            }
        }


        sizeConstraintsNotRequired.forEach{ $0.priority = .defaultHigh + 1 }
        let result = sizeConstraintsRequired + sizeConstraintsNotRequired + alignmentContraints
        NSLayoutConstraint.activate(result)
        return result
    }
    

    func getTransform(forView viewToTransform:UIView, toLookLike viewToLookLike: UIView) -> CGAffineTransform {
        
        if let superviewOfViewToTransform = viewToTransform.superview
            , let superviewOfViewToLookLike = viewToLookLike.superview
        {
            let frameTarget = superviewOfViewToTransform.convert(viewToLookLike.frame
                                                                 , from: superviewOfViewToLookLike)
            return CGAffineTransform.transform(view: viewToTransform
                                               ,toLookLike: frameTarget)
        } else {
            return .identity
        }
    }

}

