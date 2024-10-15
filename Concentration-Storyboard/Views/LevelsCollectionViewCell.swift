//
//  LevelsCollectionViewCell.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 28/02/2024.
//

import UIKit

class LevelsCollectionViewCell: UICollectionViewCell {
    enum State {
        case Locked
        case New
        case Play
        case Restart
    }
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }

    private func setupView() {
        
    }
    
    
    func animateTapAction() {
        if case .Locked = state {
            let animationPart1Duration = UIParameter.TapUnlockedAnimationDuration / 2
            let animationPart2Duration = UIParameter.TapLockedAnimationDuration - animationPart1Duration
            UIView.animate(withDuration: animationPart1Duration
                           ,delay: 0
                           ,animations: {
                self.transform = self.transform.scaledBy(x: UIParameter.AnimationScaleFactor
                                                         , y: UIParameter.AnimationScaleFactor)
            }
                           , completion: { finished in
                UIView.animate(withDuration: animationPart2Duration
                               ,delay: 0
                               ,usingSpringWithDamping: 0.1
                               ,initialSpringVelocity: 0.1
                               ,options: [.allowUserInteraction]
                               ,animations: {
                    self.transform = CGAffineTransformIdentity
                }
                )
            }
            )
        } else {
            UIView.animate(withDuration: UIParameter.TapUnlockedAnimationDuration / 2
                           ,delay: 0
                           ,animations: {
                self.transform = self.transform.scaledBy(x: UIParameter.AnimationScaleFactor
                                                         , y: UIParameter.AnimationScaleFactor)
            }
                           , completion: { finished in
                if finished {
                    UIView.animate(withDuration: UIParameter.TapUnlockedAnimationDuration / 2
                                   ,delay: 0
                                   ,animations: { self.transform = .identity }
                    )
                }
            }
            )
        }
    }
    
    @IBOutlet weak var cellBackground: RoundedShadowedView! {
        didSet {
            cellBackground.alpha = UIParameter.BackgroundAlpha
            cellBackground.cornerRadius = UIParameter.CornerRadius
            cellBackground.shadowRadius = UIParameter.Shadow.Radius
            cellBackground.shadowOpacity = UIParameter.Shadow.Opacity
            cellBackground.shadowColor = UIParameter.Shadow.Color
        }
    }
    
    @IBOutlet weak var animatedContent: UIView! {
        didSet {
            animatedContent.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var lockedEffect: UIView!
    
    @IBOutlet weak var lockLogo: UIImageView! {
        didSet {
            configureLogo(lockLogo)
            lockLogo.alpha = UIParameter.LockLogoAlpha
        }
    }
    @IBOutlet weak var playLogo: UIImageView! {
        didSet {
            configureLogo(lockLogo)
            playLogo.alpha = UIParameter.PlayLogoAlpha
        }
    }
    
    @IBOutlet weak var restartLogo: UIImageView!{
        didSet {
            configureLogo(lockLogo)
            restartLogo.alpha = UIParameter.RestartLogoAlpha
        }
    }
    
    @IBOutlet weak var bestScorePlaceholder: UIView!
    @IBOutlet weak var bestScoreContainer: UIView! {
        didSet {
            let bundle = Bundle(for: ScoreRankView.self)
            let className = String(describing: ScoreRankView.self)
            let nib = UINib(nibName: className, bundle: bundle)
            guard let scoreRankView = nib.instantiate(withOwner: self, options: nil).first as? ScoreRankView else {
                fatalError("Failed to load nib for view \(className).")
            }
            scoreRankView.translatesAutoresizingMaskIntoConstraints = false
            bestScoreContainer.addSubview(scoreRankView)
            scoreRankView.setContraints(toLookLike: bestScoreContainer, scaleBy: UIParameter.FictiveGametableToContentSize)
        }
    }
    
    var bestScoreRankView : ScoreRankView? {
        return (bestScoreContainer?.subviews.first as? ScoreRankView)
    }
    
    
    private func configureLogo(_ view:UIImageView) {
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.4
//        view.layer.shadowRadius = 5
    }

    
    @IBOutlet weak var progressionBar: ProgressionBarView!
    
    var state : State = .Play {
        didSet {
            switch(state) {
            case .Locked:
                fictiveGametable.alpha = UIParameter.LockedFictiveGametableAlpha
                playLogo.isHidden = true
                restartLogo.isHidden = true
                lockedEffect.isHidden = false
            case .New:
                fictiveGametable.alpha = UIParameter.UnlockedFictiveGametableAlpha
                playLogo.isHidden = false
                restartLogo.isHidden = true
                lockedEffect.isHidden = true
            case .Play:
                fictiveGametable.alpha = UIParameter.UnlockedFictiveGametableAlpha
                playLogo.isHidden = false
                restartLogo.isHidden = true
                lockedEffect.isHidden = true
            case .Restart:
                fictiveGametable.alpha = UIParameter.UnlockedFictiveGametableAlpha
                playLogo.isHidden = true
                restartLogo.isHidden = true
                lockedEffect.isHidden = true
            }
        }
    }
    
    func setContentVisible(animated:Bool) {
        UIView.animate(withDuration: UIParameter.SetVisibleAnimationDuration
                       ,delay: 0
                       ,usingSpringWithDamping: 0.5
                       ,initialSpringVelocity: 0.1
                       ,animations: {
            self.animatedContent.alpha = 1
            self.animatedContent.transform = CGAffineTransformIdentity
        }
                       ,completion: {
            _ in
            self.animatedContent.alpha = 1
            self.animatedContent.transform = CGAffineTransformIdentity
            
            switch(self.state) {
            case .Play, .Restart:
                if let progressionBarConfiguration = self.progressionBarConfiguration
                {
                    self.bestScorePlaceholder.isHidden = false
                    self.bestScoreContainer.alpha = 0
                    self.progressionBar.isHidden = false
                    self.progressionBar.setWithAnimation(progressionBarConfiguration, duration: 0.5)
                
//                    NSLayoutConstraint.activate([self.fictiveGametableContainerConstraintToBestScoreContainer])
//                    
                    UIView.animate(withDuration: 0.5
                                   ,delay: 0
                                   ,animations: {
                        self.layoutIfNeeded()
                        self.bestScoreContainer.alpha = 1
                    }
                    )
                }
            default:
                break
            }
        }
        )
    }
    func setContentNotVisible() {
        animatedContent.transform = CGAffineTransformIdentity.scaledBy(x: 0.01, y: 0.01)
        animatedContent.alpha = 0
        progressionBar.isHidden = true
        bestScorePlaceholder.isHidden = true
    }
    
    var numberOfCards : Int = 0 {
        didSet {
            fictiveGametable.numberOfCards = numberOfCards
        }
    }
    
    var progressionBarConfiguration : ProgressionBarView.Configuration? {
        didSet {
            progressionBar.isHidden = true
        }
    }
    
    @IBOutlet weak var fictiveGametableContainer: UIView!
    
    private(set) lazy var fictiveGametable : FictiveGametableRepresentationView = {
        let fictiveGametable = FictiveGametableRepresentationView()
        fictiveGametable.translatesAutoresizingMaskIntoConstraints = false
//        fictiveGametable.frame = fictiveGametableContainer.bounds.zoom(by: UIParameter.FictiveGametableToContentSize)
        
        fictiveGametableContainer.addSubviewFullsized(fictiveGametable)
        
        return fictiveGametable
    }()
}

extension LevelsCollectionViewCell {
    struct UIParameter {
        static let AnimationScaleFactor = 0.7
        static let TapUnlockedAnimationDuration : TimeInterval = 0.2
        static let TapLockedAnimationDuration : TimeInterval = 0.5
        static let SetVisibleAnimationDuration : TimeInterval = 0.75
        
        static let LockedFictiveGametableAlpha : CGFloat = 0.2
        static let UnlockedFictiveGametableAlpha : CGFloat = 0.8
        static let FictiveGametableToContentSize : CGFloat = 0.8
        
        static let PlayLogoAlpha : CGFloat = 0.9
        static let RestartLogoAlpha : CGFloat = 0.9
        static let LockLogoAlpha : CGFloat = 0.6
        
        static let BackgroundAlpha : CGFloat = 0.8
        static let CornerRadius : CGFloat = 10
        
        struct Shadow {
            static let Radius : CGFloat = 10
            static let Opacity : Float = 0.5
            static let Color : CGColor = UIColor.black.cgColor
        }
    }
}
