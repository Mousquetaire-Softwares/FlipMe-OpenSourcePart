//
//  EndOfGameViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 01/02/2024.
//

import UIKit
import StoreKit

protocol EndOfGameViewControllerDelegate : AnyObject {
    func restartLevel()
    func goToMenu()
    func startOtherLevel(_ levelKey: LevelKey)
}

class EndOfGameViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView.layer.cornerRadius = UIParameter.CornerRadius
        
        scoreLabel.alpha = 0
        newBestScoreImage.alpha = 0
        progressionBar.alpha = 0
        buttonsStack.alpha = 0
        mysteryCardContainer.alpha = 0
        
        if let randomNewBestScoreImage = UIParameter.NewBestScoreImages.randomElement() {
            newBestScoreImage.image = UIImage(named: randomNewBestScoreImage)
        } else {
            newBestScoreImage.image = nil
        }
        
        updateFromViewModel()
    }

    weak var delegate : EndOfGameViewControllerDelegate?

    // MARK: - General UI
    @IBOutlet weak var backgroundView: RoundedShadowedView! {
        didSet {
            backgroundView.alpha = UIParameter.BackgroundAlpha
            backgroundView.cornerRadius = UIParameter.CornerRadius
            backgroundView.shadowRadius = UIParameter.Shadow.Radius
            backgroundView.shadowOpacity = UIParameter.Shadow.Opacity
            backgroundView.shadowColor = UIParameter.Shadow.Color
        }
    }
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var buttonsStack: UIStackView!
    

    // MARK: - Actions buttons & segues
    @IBAction func restartLevelTap(_ sender: Any) {
        delegate?.restartLevel()
    }
    @IBAction func nextLevelTap(_ sender: Any) {
        if let nextLevelKey = viewModel?.nextLevelStates?.new.levelKey {
            delegate?.startOtherLevel(nextLevelKey)
        }
    }
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
    }
    
    // MARK: - ViewModel links
    var viewModel : EndOfGameViewModelProtocol? {
        didSet {
            if isViewLoaded {
                updateFromViewModel()
            }
        }
    }

    private func updateFromViewModel() {
        if let score = viewModel?.score {
            scoreRankController.set(scoreRank: score.rank
                                    , animated: true
                                    , completion:  animateScoreLabelAppearance )
            scoreLabel.text = "\(Int(score.score*100)) / 100"
        } else {
            scoreLabel.text = ""
        }
        
        newBestScoreImage.isHidden = !(viewModel?.rewards.contains(where: { $0.sameCase(as: .NewBestScore) }) ?? false)
        
        progressionBar.isHidden = viewModel?.levelStates.previous.completed ?? false
        mysteryCardController.isVisible = viewModel?.potentialRewards.contains(where: { $0.sameCase(as: .NewUnknownImage) }) ?? false

        configureNextLevel(visible: viewModel?.nextLevelStates != nil
                           , enabled: viewModel?.nextLevelStates?.previous.unlocked ?? false )
    }
    
    // MARK: - Score Rank
    var scoreRankController = ScoreRankViewController()
    
    @IBOutlet weak var scoreRankContainer: UIView! {
        didSet {
            addChild(scoreRankController)
            scoreRankContainer.addSubviewFullsized(scoreRankController.view)
            scoreRankController.didMove(toParent: self)
        }
    }

    // MARK: - Score
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var newBestScoreImage: UIImageView!
    
    private func animateScoreLabelAppearance() {
        let target = scoreLabel!
        target.transform = target.transform.scaledBy(x: 10, y: 10)
        
        UIView.animate(withDuration: UIParameter.AnimationDuration
                       , delay: UIParameter.AnimationDuration
                       , options: [.curveEaseIn]
                       , animations: {
            target.alpha = 1
            target.transform = .identity
        }
                       ,completion: {
            [weak self] _ in
            
            self?.animateNewBestScoreImageAppearance()
            
            self?.buttonsStack.alpha = 1
            self?.progressionBar.alpha = 1
            self?.mysteryCardContainer.alpha = 1
            
            self?.animateProgressionBar()
            
            self?.callReviewRequester()
        }
        )
    }

    // MARK: - Progression Bar
    @IBOutlet weak var progressionBar: ProgressionBarView!
    private func animateProgressionBar() {
        guard let viewModel else { return }
        
        if viewModel.levelStates.previous.completed == true {
            self.progressionBar.setWithAnimation(.Completed
                                                 ,duration: 0)
        } else {
            
            let progressionBarConfiguration : ProgressionBarView.Configuration = {
                if viewModel.levelStates.new.completed == true {
                    return .ShowCompletion(from: viewModel.levelStates.previous.points
                                           , endOfBar: viewModel.levelStates.new.neededPointsToComplete
                                           , barCompletion: self.progressionBarVfxParticles)
                } else {
                    return .ShowProgression(from: viewModel.levelStates.previous.points
                                            , to: viewModel.levelStates.new.points
                                            , endOfBar: viewModel.levelStates.new.neededPointsToComplete
                                            , infiniteAnimation: true)
                }
            }()
            
            self.progressionBar.setWithAnimation(progressionBarConfiguration
                                                 , duration: UIParameter.ProgressionBarAnimationDuration
                                                 , completion: {
                [weak self] _ in
                
                let newNextLevelUnlockedAnimation = {
                    if let _ = self?.viewModel?.newLevelsUnlocked.first {
                        self?.animateNewNextLevelUnlocked()
                    }
                }
                
                if let newImageUnlocked = viewModel.newImageUnlocked {
                    self?.animateMysteryCardIsWon(newImageUnlocked, completion: newNextLevelUnlockedAnimation)
                } else {
                    newNextLevelUnlockedAnimation()
                }
                
            }
            )
        }
    }
    
    private func progressionBarVfxParticles(_ finished:Bool) {
        guard finished else { return }
        
        let vfxParticles = VfxParticlesExplosionViewController(numberOfParticles: UIParameter.ProgressionBarCompletedParticles
                                                               , particlesImages: ParticlesLibraryViewModel.Stars.Green.UIImages
                                                               , duration: UIParameter.ProgressionBarCompletedAnimationDuration
                                                               , maximumDelayByParticle: UIParameter.ProgressionBarCompletedAnimationDuration / 5
                                                               , delay: 0)
        if let containerView = view
            , let vfxView = vfxParticles.view
        {
            self.addChild(vfxParticles)
            containerView.addSubview(vfxView)
            vfxView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                vfxView.widthAnchor.constraint(equalTo: vfxView.heightAnchor, multiplier: 1)
                ,vfxView.heightAnchor.constraint(equalTo: progressionBar.heightAnchor, multiplier: 5)
                ,vfxView.centerXAnchor.constraint(equalTo: progressionBar.rightAnchor)
                ,vfxView.centerYAnchor.constraint(equalTo: progressionBar.centerYAnchor)
            ])
            
            vfxParticles.didMove(toParent: self)
            containerView.layoutIfNeeded()
            vfxParticles.startAnimation()
        }
    }

    // MARK: - Best Score
    private func animateNewBestScoreImageAppearance() {
        let target = newBestScoreImage!
        
        target.alpha = 0
        target.transform = target.transform.scaledBy(x: 0, y: 0)
        
        UIView.animate(withDuration: UIParameter.AnimationDuration * 2
                       , delay: 0
                       , options: [.curveEaseIn]
                       , animations: {
            target.alpha = 1
            target.transform = .identity
        }
        )
    }
    
    // MARK: - Mystery Card
    lazy var mysteryCardController = PlayableCardViewController(delegate: self
                                                                , roundedAngleFactorAtCreation: 0)
    
    @IBOutlet weak var mysteryCardContainer: UIView! {
        didSet {
            mysteryCardContainer.isUserInteractionEnabled = false
            addChild(mysteryCardController)
            
            mysteryCardContainer.addSubviewFullsized(mysteryCardController.view)
            
            mysteryCardController.didMove(toParent: self)
            mysteryCardController.cardView.movingContentView.layer.transform = CATransform3DIdentity
            mysteryCardController.showMysteryLabelOnFaceDown(true)
        }
    }
    
    private func animateMysteryCardIsWon(_ imageName: ImageName, completion: @escaping (()->())) {
        
        presentSafebox(showingNewUnlockedImage: imageName) {
            self.mysteryCardController.viewModel = {
                (key:0
                 ,value:CardViewModel(matchingCardsModel: MatchingCardsModel(image: .Single(imageName: imageName))
                                      , location: Location2D(row: 0, column: 0)))
            }()
            self.mysteryCardController.showMysteryLabelOnFaceDown(false)
            self.mysteryCardController.isVisible = true
            
            self.mysteryCardController.cardView.setFaceUp(true
                                                          , action: .AnimateAndSwipeContentView(randomOrientation: false)
                                                          , completion: {
                _ in
                self.mysteryCardContainer.isUserInteractionEnabled = true
                completion()
            }
            )
        }
    }
    
    private var safeboxDidDismissCompletion : (()->())?
    private func presentSafebox(showingNewUnlockedImage newUnlockedImage: ImageName, completion: @escaping (()->())) {
        let sb = UIStoryboard(name: SafeboxViewController.UIDesign.StoryboardName, bundle: nil)
        let vc = sb.instantiateViewController(identifier: SafeboxViewController.UIDesign.StoryboardId
                                              ,creator: {
            coder in
            return SafeboxViewController(ImagesLibraryModel.Shared
                                         , configuration: .ShowingNewUnlockedImage(image: newUnlockedImage)
                                         , coder: coder)
        })
            
        vc.modalPresentationStyle = .pageSheet
        vc.modalTransitionStyle = .coverVertical
        vc.presentationController?.delegate = self
        vc.dismissCompletion = {
            if let pc = vc.presentationController {
                self.presentationControllerDidDismiss(pc)
            }
        }
        safeboxDidDismissCompletion = completion
        
        self.present(vc, animated: true)
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        if let safeboxDidDismissCompletion {
            self.safeboxDidDismissCompletion = nil
            safeboxDidDismissCompletion()
        }
    }
    // MARK: - Next Level
    
    @IBOutlet weak var nextLevel: UIButton!
    private func configureNextLevel(visible:Bool, enabled:Bool) {
        nextLevel.isEnabled = enabled
        
        if visible {
            if enabled {
                nextLevel.alpha = 1
            } else {
                nextLevel.alpha = UIParameter.NextLevelButtonAlphaIfDisabled
            }
        } else {
            nextLevel.alpha = 0
        }
    }
    private func animateNewNextLevelUnlocked() {
        
        let vfxParticles : VfxParticlesExplosionViewController
        let vfxBouncing : VfxBouncingViewController
        
        if (viewModel?.rewards.contains(where: { $0.sameCase(as: .NewStageUnlocked(0)) }) ?? false) == false {
            vfxParticles = VfxParticlesExplosionViewController(numberOfParticles: UIParameter.RewardNextLevelUnlockedParticles
                                                               , particlesImages: ParticlesLibraryViewModel.Stars.Yellow.UIImages
                                                               , duration: UIParameter.RewardNextLevelUnlockedAnimationDuration
                                                               , maximumDelayByParticle: UIParameter.RewardNextLevelUnlockedAnimationDuration / 2
                                                               , delay: 0)
            
            vfxBouncing = VfxBouncingViewController(viewToMakeBounce: nextLevel
                                                    , duration: UIParameter.RewardNextLevelUnlockedAnimationDuration
                                                    , delay: 0)
        }
        // If new level unlocked is also a new stage, we apply other parameters with twice more visual effects
        else {
            vfxParticles = VfxParticlesExplosionViewController(numberOfParticles: UIParameter.RewardNextLevelUnlockedParticles * 2
                                                               , particlesImages: ParticlesLibraryViewModel.Stars.Blue.UIImages
                                                               , duration: UIParameter.RewardNextLevelUnlockedAnimationDuration * 2
                                                               , maximumDelayByParticle: UIParameter.RewardNextLevelUnlockedAnimationDuration
                                                               , delay: 0)
            
            vfxBouncing = VfxBouncingViewController(viewToMakeBounce: nextLevel
                                                    , duration: UIParameter.RewardNextLevelUnlockedAnimationDuration * 2
                                                    , delay: 0)
        }
        if let containerView = view
            , let vfxView = vfxParticles.view
        {
            self.addChild(vfxParticles)
            containerView.addSubview(vfxView)
            vfxView.translatesAutoresizingMaskIntoConstraints = false
            vfxView.setContraints(toLookLike: nextLevel, scaleBy: 2)
            
            vfxParticles.didMove(toParent: self)
            containerView.layoutIfNeeded()
            vfxBouncing.startAnimation()
            vfxParticles.startAnimation()
        }
        configureNextLevel(visible: true
                           , enabled: viewModel?.nextLevelStates?.new.unlocked ?? false)
    }
    
    // MARK: Requesting reviews
    private func callReviewRequester() {
        if let viewModel, let windowScene = view.window?.windowScene {
            ReviewRequesterModel.Shared.gameAchievement(finalLevelState: viewModel.levelStates.new
                                                        , finalScore: viewModel.score) {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    

}

extension EndOfGameViewController : PlayableCardViewControllerDelegate {
    func cardPlaceholder(at location: Location2D) -> UIView? { nil }
    func faceUp(_: CardViewController) -> Bool { mysteryCardController.viewModel != nil }
    func putTwoUnmatchedCardsFaceDown() throws { }
    func hideHelperForSwiping() { }
    var cardSize: CGFloat { mysteryCardContainer.frame.width }
}


extension EndOfGameViewController {
    struct UIDesign {
        static let StoryboardName = "Main"
        static let IdentifierInStoryboard = "EndOfGame"
    }
    struct UIParameter {
        static let AnimationDuration = 0.5
        static let CornerRadius : CGFloat = 40
        static let BackgroundAlpha : CGFloat = 0.9
        static let NextLevelButtonAlphaIfDisabled : CGFloat = 0.5
        
        static let RewardNextLevelUnlockedAnimationDuration : TimeInterval = 2
        static let RewardNextLevelUnlockedParticles = 15
        
        static let ProgressionBarAnimationDuration : TimeInterval = 2
        static let ProgressionBarCompletedAnimationDuration : TimeInterval = 2
        static let ProgressionBarCompletedParticles = 15
        
        static let NewBestScoreImages = ["cup-1"] // "blue-happyface-2","green-happyface-2"]
        
        struct Shadow {
            static let Radius : CGFloat = 30
            static let Opacity : Float = 2
            static let Color : CGColor = UIColor.black.cgColor
        }
    }
}
