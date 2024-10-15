//
//  ProgressionBarView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 01/03/2024.
//

import UIKit

@IBDesignable
class ProgressionBarView: UIView, NibLoadable {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }
    
    func setupView() {
        background?.layer.cornerRadius = self.bounds.height / 2
        
        Bar.allCases.forEach{
            self[viewOf: $0].layer.cornerRadius = self.bounds.height / 3
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
        
    }
    
    private func setupBackground() {
        
    }
    
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var wholeBar: UIView!
    
    @IBOutlet weak var progressBarUncompletedFinal: UIView!
    @IBOutlet weak var progressBarProgression: UIView!
    @IBOutlet weak var progressBarUncompletedStart: UIView!
    @IBOutlet weak var progressBarCompleted: UIView!

    @IBOutlet weak var progressBarUncompletedFinalWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBarProgressionWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBarUncompletedStartWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressBarCompletedWidthConstraint: NSLayoutConstraint!
    
    private subscript(viewOf bar:Bar) -> UIView {
        get {
            switch(bar) {
            case .UncompletedFinal:
                return progressBarUncompletedFinal
            case .Progression:
                return progressBarProgression
            case .UncompletedStart:
                return progressBarUncompletedStart
            case .Completed:
                return progressBarCompleted
            }
        }
    }
    private subscript(widthConstraintOf bar:Bar) -> NSLayoutConstraint {
        get {
            switch(bar) {
            case .UncompletedFinal:
                return progressBarUncompletedFinalWidthConstraint
            case .Progression:
                return progressBarProgressionWidthConstraint
            case .UncompletedStart:
                return progressBarUncompletedStartWidthConstraint
            case .Completed:
                return progressBarCompletedWidthConstraint
            }
        }
        set {
            switch(bar) {
            case .UncompletedFinal:
                progressBarUncompletedFinalWidthConstraint = newValue
            case .Progression:
                progressBarProgressionWidthConstraint = newValue
            case .UncompletedStart:
                progressBarUncompletedStartWidthConstraint = newValue
            case .Completed:
                progressBarCompletedWidthConstraint = newValue
            }
        }
    }
    
    enum Bar : CaseIterable {
        case UncompletedFinal, Progression, UncompletedStart, Completed
    }
    
    
    
    private func resetProgressBarWidthConstraint(_ bar:Bar, newMultiplier multiplier:CGFloat) {
        
        if self[widthConstraintOf: bar].isActive {
            NSLayoutConstraint.deactivate([self[widthConstraintOf: bar]])
        }
        let newWidthConstraint = {
            NSLayoutConstraint(item: self[viewOf: bar]
                               , attribute: .width
                               , relatedBy: .equal
                               , toItem: wholeBar
                               , attribute: .width
                               , multiplier: multiplier
                               , constant: 0)
        }()
        NSLayoutConstraint.activate([newWidthConstraint])
        
        self[widthConstraintOf: bar] = newWidthConstraint
    }
    
    enum Configuration {
        case Completed
        case Uncompleted(value:Float, endOfBar:Float)
        case ShowProgression(from:Float, to:Float, endOfBar:Float, infiniteAnimation:Bool)
        case ShowCompletion(from:Float, endOfBar:Float, barCompletion:((Bool)->())?)
        
        fileprivate var barParameters : BarParameters {
            switch(self) {
            case .Completed:
                return BarParameters(animationStartValue: 0, animationFinalValue: 100, endOfBarValue: 100)
            case .Uncompleted(value: let value, endOfBar: let endOfBar):
                return BarParameters(animationStartValue: 0, animationFinalValue: value, endOfBarValue: endOfBar)
            case .ShowProgression(from: let from, to: let to, endOfBar: let endOfBar, _):
                return BarParameters(animationStartValue: from, animationFinalValue: to, endOfBarValue: endOfBar)
            case .ShowCompletion(from: let from, endOfBar: let endOfBar, _):
                return BarParameters(animationStartValue: from, animationFinalValue: endOfBar, endOfBarValue: endOfBar)
            }
        }
    }
    
    fileprivate struct BarParameters {
        let animationStartValue: Float, animationFinalValue: Float, endOfBarValue: Float, minimumValueToShow: Float
        let progressBarStartWidthMultiplier : CGFloat
        let progressBarFinalWidthMultiplier : CGFloat
        
        init(animationStartValue: Float, animationFinalValue: Float, endOfBarValue: Float) {
            self.endOfBarValue = endOfBarValue
            self.minimumValueToShow = 0
            // bar values cannot be lower than 1 (for correct UI constraints calculations)
            self.animationStartValue = max(1, min(max(animationStartValue, minimumValueToShow), endOfBarValue))
            self.animationFinalValue = max(1, min(max(animationFinalValue, minimumValueToShow), endOfBarValue))
            progressBarStartWidthMultiplier = CGFloat(self.animationStartValue)/CGFloat(endOfBarValue)
            progressBarFinalWidthMultiplier = CGFloat(self.animationFinalValue)/CGFloat(endOfBarValue)
        }
    }
    
    
    func setWithAnimation(_ configuration:Configuration
                          , duration:TimeInterval
                          , completion:((Bool)->Void)? = nil) 
    {
        switch(configuration) {
        case .Completed:
            animateOneBarValue(.Completed
                               , with: configuration.barParameters
                               , duration: duration
                               , completion: completion)
        case .Uncompleted(_, _):
            animateOneBarValue(.UncompletedFinal
                               , with: configuration.barParameters
                               , duration: duration
                               , completion: completion)
        case .ShowProgression(_, _, _, let infiniteAnimation):
            animateShowingProgression(of: configuration.barParameters
                                      , withInfiniteAnimation: infiniteAnimation
                                      , duration: duration
                                      , completionOfFirstAnimation: completion)
        case .ShowCompletion(_,_, let barCompletion):
            animateShowingCompletion(with: configuration.barParameters
                                     , duration: duration
                                     , barCompletion: barCompletion
                                     , completion: completion)
        }
        
    }
    
    private func hideAllBars() {
        Bar.allCases.forEach{
            self[viewOf: $0].isHidden = true
            self[viewOf: $0].alpha = 1
        }
    }
    
    private func animateOneBarValue(_ bar:Bar
                                    , with barParameters:BarParameters
                                    , duration:TimeInterval
                                    , completion:((Bool)->Void)?)
    {
        hideAllBars()
        self[viewOf: bar].isHidden = false

        // Setting up constraints for progress bar before animation
        resetProgressBarWidthConstraint(bar, newMultiplier: barParameters.progressBarStartWidthMultiplier)
        
        // Ready for the first frame
        layoutIfNeeded()
        
        // Setting up constraints for progress bar animation
        UIView.animate(withDuration: duration
                       , delay: 0
                       , options: [.curveEaseOut]
                       , animations: {
            self.resetProgressBarWidthConstraint(bar, newMultiplier: barParameters.progressBarFinalWidthMultiplier)
            self.layoutIfNeeded()
        }
                       , completion: completion
        )
    }
    
    
    private func animateShowingProgression(of barParameters:BarParameters
                                           , withInfiniteAnimation:Bool
                                           , duration:TimeInterval
                                           , completionOfFirstAnimation completion:((Bool)->Void)?)
    {
        hideAllBars()
        self[viewOf: .UncompletedStart].isHidden = false
        self[viewOf: .UncompletedFinal].isHidden = false
        self[viewOf: .UncompletedFinal].alpha = 0
        self[viewOf: .Progression].isHidden = false

        // Setting up constraints for progress bar before animation
        resetProgressBarWidthConstraint(.UncompletedStart, newMultiplier: barParameters.progressBarStartWidthMultiplier)
        resetProgressBarWidthConstraint(.Progression, newMultiplier: barParameters.progressBarStartWidthMultiplier)
        resetProgressBarWidthConstraint(.UncompletedFinal, newMultiplier: barParameters.progressBarFinalWidthMultiplier)
        
        // Ready for the first frame
        layoutIfNeeded()
        
        // Setting up constraints for progress bar animation
        animateProgressionBar(with: barParameters, duration: duration, restartWhenFinished: withInfiniteAnimation, completion: completion)
    }
    
    /// MARK: - Progress bar neverending animation
    private func animateProgressionBar(with barParameters:BarParameters
                                       , duration:TimeInterval
                                       , restartWhenFinished:Bool
                                       , completion:((Bool)->Void)?) 
    {
        self[viewOf: .Progression].alpha = 1
        self.resetProgressBarWidthConstraint(.Progression
                                             , newMultiplier: barParameters.progressBarStartWidthMultiplier)
        self.layoutIfNeeded()
    
        UIView.animate(withDuration: duration
                       , delay: 0
                       , options: [.curveLinear]
                       , animations: {
            [weak self] in
            
            if let self {
                self.resetProgressBarWidthConstraint(.Progression
                                                     , newMultiplier: barParameters.progressBarFinalWidthMultiplier)
                
                self.layoutIfNeeded()
                
            }
        }
                       , completion: {
            [weak self] finished in
            
            self?[viewOf: .UncompletedFinal].alpha = 1
            
            completion?(finished)
            
            UIView.animate(withDuration: duration / 2
                           , delay: 0
                           , options: [.curveLinear]
                           , animations: {
                [weak self] in
                
                self?[viewOf: .Progression].alpha = 0
                    
            }
                           , completion: {
                [weak self] finished in
                if restartWhenFinished {
                    self?.animateProgressionBar(with: barParameters, duration: duration, restartWhenFinished: true, completion: nil)
                }
            }
            )
        }
        )
    }
    
    private func animateShowingCompletion(with barParameters:BarParameters
                                          , duration:TimeInterval
                                          , barCompletion:((Bool)->Void)?
                                          , completion:((Bool)->Void)?)
    {
        hideAllBars()
        self[viewOf: .UncompletedStart].isHidden = false
        self[viewOf: .Completed].isHidden = false
        self[viewOf: .Completed].alpha = 0
        self[viewOf: .Progression].isHidden = false

        // Setting up constraints for progress bar before animation
        resetProgressBarWidthConstraint(.UncompletedStart, newMultiplier: barParameters.progressBarStartWidthMultiplier)
        resetProgressBarWidthConstraint(.Progression, newMultiplier: barParameters.progressBarStartWidthMultiplier)
        resetProgressBarWidthConstraint(.Completed, newMultiplier: barParameters.progressBarFinalWidthMultiplier)
        
        // Ready for the first frame
        layoutIfNeeded()
        
        // Setting up constraints for progress bar animation
        UIView.animate(withDuration: duration
                       , delay: 0
                       , options: [.curveLinear]
                       , animations: {
            self.resetProgressBarWidthConstraint(.Progression, newMultiplier: barParameters.progressBarFinalWidthMultiplier)
            self.layoutIfNeeded()
        }
                       , completion: {
            [weak self] finished in
            
            barCompletion?(finished)
            
            UIView.animate(withDuration: duration
                           , delay: 0
                           , options: [.curveEaseIn]
                           , animations: {
                [weak self] in
                
                self?[viewOf: .Completed].alpha = 1
                    
            }
                           , completion: completion
            )
        }
        )
    }
    

}

extension ProgressionBarView {
    struct UIParameter {
    }
}
