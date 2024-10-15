//
//  ScoreRankViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 02/02/2024.
//

import UIKit

class ScoreRankViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let bundle = Bundle(for: ScoreRankView.self)
        let className = String(describing: ScoreRankView.self)
        let nib = UINib(nibName: className, bundle: bundle)
        guard let scoreRankView = nib.instantiate(withOwner: self, options: nil).first as? ScoreRankView else {
            fatalError("Failed to load nib for view \(className).")
        }
        scoreRankView.translatesAutoresizingMaskIntoConstraints = false
        self.view = scoreRankView
        self.scoreRankView = scoreRankView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImages()
    }

    private var scoreRankView : ScoreRankView!
    
    private(set) var viewModel : ScoreRank?
    
    
    private func setupImages() {
        if let ranksImages = UIParameter.ImagesForRanks.randomElement() {
            let badRankImage = UIImage(named: ranksImages.bad)
            let goodRankImage = UIImage(named: ranksImages.good)
            let perfectRankImage = UIImage(named: ranksImages.perfect)
            
            scoreRankView.setupImages(badRankImage: badRankImage
                                    , goodRankImage: goodRankImage
                                    , perfectRankImage: perfectRankImage)
        }
        
    }
    
    
    func set(scoreRank:ScoreRank?, animated:Bool = false, completion:(()->Void)? = nil) {
        setupImages()
        viewModel = scoreRank
        if animated {
            updateFromViewModelWithAnimation(completion: completion)
        } else {
            scoreRankView.showRank(viewModel)
        }
    }
    
    private func updateFromViewModelWithAnimation(completion: (()->Void)?) {
        scoreRankView.reset()
        guard let viewModel = self.viewModel else { return }
        
        let steps : Int
        switch(viewModel) {
        case .Zero: steps = 1
        case .One: steps = 1
        case .Two: steps = 2
        case .Three: steps = 3
        case .Four: steps = 4
        }
        var totalDuration : TimeInterval = 0
        
        let delay1 = animationRandomDelay
        totalDuration = delay1 + UIParameter.AnimationDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + delay1) {
            
            [weak self] in
            if let self {
                switch(viewModel) {
                case .Zero:
                    let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.badRank
                                                                                  , configuration: ParticlesExplosionConfiguration(forRank: .Zero)
                                                                                  , delay: UIParameter.ParticlesAnimationDelay)
                    self.animateElementAppearance(self.scoreRankView.badRank
                                                  , duration: UIParameter.AnimationDuration
                                                  , vfxParticles: vfxParticles)
                case .One:
                    let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.goodRank1
                                                                                  , configuration: ParticlesExplosionConfiguration(forRank: .One)
                                                                                  , delay: UIParameter.ParticlesAnimationDelay)
                    self.animateElementAppearance(self.scoreRankView.goodRank1
                                                  , duration: UIParameter.AnimationDuration
                                                  , vfxParticles: vfxParticles)
                case .Two:
                    let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.goodRank1
                                                                                  , configuration: ParticlesExplosionConfiguration(forRank: .One)
                                                                                  , delay: UIParameter.ParticlesAnimationDelay)
                    self.animateElementAppearance(self.scoreRankView.goodRank2Image1
                                                  , makeItLookLike: self.scoreRankView.goodRank1
                                                  , duration: UIParameter.AnimationDuration
                                                  , vfxParticles: vfxParticles)
                case .Three:
                    fallthrough
                case .Four:
                    let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.goodRank1
                                                                                  , configuration: ParticlesExplosionConfiguration(forRank: .One)
                                                                                  , delay: UIParameter.ParticlesAnimationDelay)
                    self.animateElementAppearance(self.scoreRankView.goodRank3Line2Image1
                                                  , makeItLookLike: self.scoreRankView.goodRank1
                                                  , duration: UIParameter.AnimationDuration
                                                  , vfxParticles: vfxParticles)
                }
            }
        }
        
        let delay2 = delay1 + UIParameter.AnimationDuration + animationRandomDelay
        if steps > 1 {
            totalDuration = delay2 + UIParameter.AnimationDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay2) {
                [weak self] in
                if let self {
                    switch(viewModel) {
                    case .Two:
                        self.animateElementMove(self.scoreRankView.goodRank2Image1)
                        let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.goodRank2Image2
                                                                                      , configuration: ParticlesExplosionConfiguration(forRank:.Two)
                                                                                      , delay: UIParameter.ParticlesAnimationDelay)
                        self.animateElementAppearance(self.scoreRankView.goodRank2Image2
                                                      , duration: UIParameter.AnimationDuration
                                                      , vfxParticles: vfxParticles)
                    case .Three:
                        fallthrough
                    case .Four:
                        self.animateElementMove(self.scoreRankView.goodRank3Line2Image1
                                                , makeItLookLike: self.scoreRankView.goodRank2Image1)
                        let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.goodRank2Image2
                                                                                      , configuration: ParticlesExplosionConfiguration(forRank:.Two)
                                                                                      , delay: UIParameter.ParticlesAnimationDelay)
                        self.animateElementAppearance(self.scoreRankView.goodRank3Line2Image2
                                                      , makeItLookLike: self.scoreRankView.goodRank2Image2
                                                      , duration: UIParameter.AnimationDuration
                                                      , vfxParticles: vfxParticles)
                    default: break
                    }
                }
            }
        }
        let delay3 = delay2 + UIParameter.AnimationDuration + animationRandomDelay
        if steps > 2 {
            totalDuration = delay3 + UIParameter.AnimationDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay3) {
                [weak self] in
                if let self {
                    self.animateElementMove(self.scoreRankView.goodRank3Line2Image1)
                    self.animateElementMove(self.scoreRankView.goodRank3Line2Image2)
                    let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.goodRank3Line1Image1
                                                                                  , configuration: ParticlesExplosionConfiguration(forRank:.Three)
                                                                                  , delay: UIParameter.ParticlesAnimationDelay)
                    self.animateElementAppearance(self.scoreRankView.goodRank3Line1Image1
                                                  , duration: UIParameter.AnimationDuration
                                                  , vfxParticles: vfxParticles)
                }
            }
        }
        let delay4 = delay3 + UIParameter.AnimationDuration + animationRandomDelay
        if steps > 3 {
            totalDuration = delay4 + UIParameter.AnimationDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay4) {
                [weak self] in
                if let self {
                    self.animateElementMove(self.scoreRankView.goodRank3Line2Image1, makeItLookLike: self.scoreRankView.goodRank1, thenHide: true)
                    self.animateElementMove(self.scoreRankView.goodRank3Line2Image2, makeItLookLike: self.scoreRankView.goodRank1, thenHide: true)
                    self.animateElementMove(self.scoreRankView.goodRank3Line1Image1, makeItLookLike: self.scoreRankView.goodRank1, thenHide: true)
                    let vfxParticles = self.createAndAnimateVfxParticlesExplosion(self.scoreRankView.perfectRank
                                                                                  , configuration: ParticlesExplosionConfiguration(forRank:.Four)
                                                                                  , delay: UIParameter.ParticlesAnimationDelay)
                    self.animateElementAppearance(self.scoreRankView.perfectRank
                                                  , duration: UIParameter.AnimationDuration
                                                  , vfxParticles: vfxParticles)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            completion?()
        }
    }
    
    
    private func animateElementMove(_ target:UIView?
                                    , makeItLookLike viewFrameTarget:UIView? = nil
                                    , thenHide: Bool = false)
    {
        guard let target else { return }
        
        UIView.animate(withDuration: UIParameter.AnimationDuration
                       , animations: {
            if let viewFrameTarget {
                target.transform = .identity
                target.transform = CGAffineTransform.transform(view: target
                                                               , toLookLike: viewFrameTarget.frame
                                                               , fromView: viewFrameTarget.superview)
            } else {
                target.transform = .identity
            }
            if thenHide {
                target.alpha = 0
            }
        }
        )
    }
    private func animateElementAppearance(_ target:UIView?
                                          , makeItLookLike viewFrameTarget:UIView? = nil
                                          , duration: TimeInterval
                                          , vfxParticles: VfxParticlesExplosionViewController?)
    {
        guard let target else { return }
        
        
        target.alpha = 0
        let finalTransform: CGAffineTransform
        if let viewFrameTarget {
            finalTransform = CGAffineTransform.transform(view: target
                                                         , toLookLike: viewFrameTarget.frame
                                                         , fromView: viewFrameTarget.superview)
        } else {
            finalTransform = .identity
        }
        target.transform = target.transform.scaledBy(x: 10, y: 10)
        
        UIView.animate(withDuration: duration
                       , delay: 0
                       , options: [.curveEaseIn]
                       , animations: {
            target.alpha = 1
            target.transform = finalTransform
        }
                       , completion: {
            _ in
            vfxParticles?.view.superview?.alpha = 1
            self.view.layoutIfNeeded()
        }
        )
    }
    
    private weak var lastVfxParticles : VfxParticlesExplosionViewController? = nil
    
    struct ParticlesExplosionConfiguration {
        init(forRank rank:ScoreRank) {
            switch(rank) {
            case .Zero:
                self.numberOfParticles = 5
                self.particlesImages = ParticlesLibraryViewModel.Stars.Yellow.UIImages
                self.duration = UIParameter.AnimationDuration
            case .One:
                self.numberOfParticles = 10
                self.particlesImages = ParticlesLibraryViewModel.Stars.Yellow.UIImages
                self.duration = UIParameter.AnimationDuration
            case .Two:
                self.numberOfParticles = 20
                self.particlesImages = ParticlesLibraryViewModel.Stars.Yellow.UIImages + ParticlesLibraryViewModel.Stars.Green.UIImages
                self.duration = UIParameter.AnimationDuration * 1.25
            case .Three:
                self.numberOfParticles = 30
                self.particlesImages = ParticlesLibraryViewModel.Stars.Yellow.UIImages + ParticlesLibraryViewModel.Stars.Green.UIImages + ParticlesLibraryViewModel.Stars.Pink.UIImages
                self.duration = UIParameter.AnimationDuration * 1.75
            case .Four:
                self.numberOfParticles = 50
                self.particlesImages = ParticlesLibraryViewModel.Stars.UIImages
                self.duration = UIParameter.AnimationDuration * 3
            }
        }
        
        let numberOfParticles:Int
        let particlesImages : [UIImage]
        let duration: TimeInterval
    }
    
    
    
    private func createAndAnimateVfxParticlesExplosion(_ target:UIView
                                                       , configuration: ParticlesExplosionConfiguration
                                                       , delay: TimeInterval) -> VfxParticlesExplosionViewController?
    {
        if let lastVfxParticles {
            UIView.animate(withDuration: delay
                           , delay: 0
                           , options: [.curveEaseOut]
                           , animations: {
                lastVfxParticles.view.superview?.alpha = 0
            }
            )
        }
        
        let vfx = VfxParticlesExplosionViewController(numberOfParticles: configuration.numberOfParticles
                                                      , particlesImages: configuration.particlesImages
                                                      , duration: configuration.duration
                                                      , maximumDelayByParticle: 0
                                                      , delay: delay
                                                      , completion: nil)
        if let container = self.view
            , let vfxView = vfx.view
        {
            self.addChild(vfx)
            vfxView.translatesAutoresizingMaskIntoConstraints = false
            let subContainer = UIView()
            subContainer.alpha = 0
            container.addSubview(subContainer)
            subContainer.translatesAutoresizingMaskIntoConstraints = false
            subContainer.setContraints(toLookLike: target)
            subContainer.addSubviewFullsized(vfxView)
            container.layoutIfNeeded()
            vfx.didMove(toParent: self)
            
            vfx.startAnimation()
            lastVfxParticles = vfx
            return vfx
        } else {
            return nil
        }
    }
}

extension ScoreRankViewController {
    struct UIParameter {
        static let AnimationDuration : TimeInterval = 0.5
        static let ParticlesAnimationDelay : TimeInterval = 0.5
        static let AnimationStepDurationRange : ClosedRange<Float> = (0.2...0.6)
        
        static let ImagesForRanks : [(bad:ImageName,good:ImageName,perfect:ImageName)] = [
            ("reward-blue-happyface-1", "reward-blue-star-1-simple", "reward-blue-star-1-full")
            ,("reward-green-happyface-1", "reward-green-star-1-simple", "reward-green-star-1-full")
            ,("reward-moon-1.png", "reward-sun-1.png", "reward-special-sun-1.png")
            ,("reward-pink-happyface-1.png", "reward-pink-star-1-simple.png", "reward-pink-star-1-full.png")
            ,("reward-yellow-happyface-2.png", "reward-yellow-star-1-simple.png", "reward-yellow-star-1-full.png")
            // Image quality too low for this :
            //            ,("reward-yellow-happyface-3.png", "reward-yellow-star-2-simple.png", "reward-yellow-star-2-full.png")
        ]
            // Another selection, from card images - one day maybe ?
            //        static let ImagesForBadRank = ["064","029","069","038","026","008"]
            //        static let ImagesForGoodRank = ["055","056","057","058","043"]
            //        static let ImagesForPerfectRank = ["062","030","068"]
            
    }
    var animationRandomDelay : TimeInterval { TimeInterval(Float.random(in: UIParameter.AnimationStepDurationRange)) }
}
