//
//  SafeboxViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 13/03/2024.
//

import UIKit

class SafeboxViewController: UIViewController {
    enum Configuration { case ShowingContentWithRandomAnimation, ShowingNewUnlockedImage(image:ImageName) }
    
    init?(_ library:ImagesLibraryModelProtocol
          , configuration:Configuration
          , coder:NSCoder) 
    {
        self.viewModel = library
        self.configuration = configuration
        super.init(coder: coder)
        
        switch(configuration) {
        case .ShowingContentWithRandomAnimation:
            instantiateControllers(from: library, considerAsNewUnlocked: nil)
        case .ShowingNewUnlockedImage(let image):
            instantiateControllers(from: library, considerAsNewUnlocked: image)
        }
    }
    
    @available(*, unavailable)
    required init?(coder:NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
    private let configuration:Configuration

    // MARK: - Initialization
    private var initialSetupLaunched = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initialSetupLaunched {
            initialSetupLaunched = true
            
            createAllCellsInFictiveGametable()
            
            switch(self.configuration) {
            case .ShowingContentWithRandomAnimation:
                self.animateShowingAllCardsWithRandomOrder()
                self.closeButton.isHidden = false
            case .ShowingNewUnlockedImage(let image):
                self.animateShowingNewUnlockedImage(image: image)
                self.closeButton.isHidden = true
            }
        }
    }

    // MARK: - Gestures & action buttons
    var dismissCompletion: (() -> ())?
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeButtonTapAction(_ sender: Any) {
        dismiss(animated: true)
        dismissCompletion?()
    }
//    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        super.dismiss(animated: flag, completion: completion)
//        dismissCompletion?()
//    }
    
    // MARK: - ViewModel & Controllers management
    private var viewModel : ImagesLibraryModelProtocol
    private var unlockedImagesControllers = [PresentationCardViewController]()
    private var lockedImagesControllers = [PresentationCardViewController]()
    private var newUnlockedImagesControllers = [PresentationCardViewController]()
    private var allControllers = [PresentationCardViewController]()
    
    private func instantiateControllers(from imagesLibrary:ImagesLibraryModelProtocol, considerAsNewUnlocked:ImageName?) {
        unlockedImagesControllers = []
        lockedImagesControllers = []
        newUnlockedImagesControllers = []
        
        var imagesToConsiderUnlocked = [ImageName]()
        if let considerAsNewUnlocked {
            imagesToConsiderUnlocked.append(considerAsNewUnlocked)
            
            let cardController = PresentationCardViewController(imageName: considerAsNewUnlocked)
            addChild(cardController)
            cardController.didMove(toParent: self)
            newUnlockedImagesControllers.append(cardController)
        }
        
        for imageName in Array<ImageName>(imagesLibrary.availableSet.subtracting(imagesToConsiderUnlocked)).shuffled() {
            let cardController = PresentationCardViewController(imageName: imageName)
            addChild(cardController)
            cardController.didMove(toParent: self)
            unlockedImagesControllers.append(cardController)
        }
                                          
        for imageName in Array<ImageName>(imagesLibrary.lockedSet).shuffled() {
            let cardController = PresentationCardViewController(imageName: imageName)
            addChild(cardController)
            cardController.didMove(toParent: self)
            lockedImagesControllers.append(cardController)
        }
                                          
        allControllers = unlockedImagesControllers + newUnlockedImagesControllers + lockedImagesControllers
    }
    
    
    private func resetConstraints(of cardController:PresentationCardViewController, toLookLike placeholderView:UIView) {
        cardController.view.deactivateAllSuperviewsConstraints()
        cardController.view.setContraints(toLookLike: placeholderView)
    }

    
    

    // MARK: - UI fictive gametable
    @IBOutlet weak var fictiveGametable: GametableView!
    
    private func createAllCellsInFictiveGametable() {
        var cellsCount = fictiveGametable.cells.count
        while cellsCount < allControllers.count {
            let newCells = fictiveGametable.expandByRowOrColumn().count
            if newCells < 1 {
                break
            }
            cellsCount += newCells
        }
    }

    // MARK: - Play animation for ShowingAllCardsWithRandomOrder
    private func animateShowingAllCardsWithRandomOrder() {
        let cardsControllers = allControllers
        let cardsControllersShuffled = cardsControllers.shuffled()
        let cellsViews = fictiveGametable.cells
        let locations = fictiveGametable.matrixSize.getLocationsInNaturalOrder(requestedCount: allControllers.count)
        
        // step 1 : showing all cards shuffled
        for cardControllerIndexValue in cardsControllersShuffled.enumerated() {
            if let location = locations[safelyIndex: cardControllerIndexValue.offset]
                , let cell = cellsViews[location]
            {
                configureForProgressiveFacingUp(cardControllerIndexValue.element , in: (location:location, view:cell))
            }
        }
        
        let totalDelay : TimeInterval = {
            SafeboxViewController.UIParameter.AnimationInitialDelay
            + (Double((fictiveGametable.matrixSize.rows + fictiveGametable.matrixSize.columns)) + 1) * CardView.UIParameter.SetFaceUpAnimationDuration
        }()
        
        // Step 2 : reordering
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay
                                      , execute: {
            UIView.animate(withDuration: 1
                           , animations: {
                
                for cardControllerIndexValue in cardsControllers.enumerated() {
                    if let location = locations[safelyIndex: cardControllerIndexValue.offset]
                        , let cell = cellsViews[location]
                    {
                        self.resetConstraints(of: cardControllerIndexValue.element
                                              , toLookLike: cell)
                    }
                }
                self.view.layoutIfNeeded()
            }
            )
        }
        )
    }
    
    private func configureForProgressiveFacingUp(_ cardController:PresentationCardViewController, in cell:(location:Location2D,view:UIView)) {
        fictiveGametable.addSubview(cardController.view)
        cell.view.setContraints(toLookLike: cardController.view)
        cardController.isVisible = true
        let delay : TimeInterval = 1 + Double((cell.location.row + cell.location.column)) * CardView.UIParameter.SetFaceUpAnimationDuration
        
        if unlockedImagesControllers.contains(cardController)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay
                                          , execute: {
                cardController.setFaceUp(value: true, animated: true)
            }
            )
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay
                                          , execute: {
                cardController.setFaceUp(value: true, animated: true, completion: {
                    _ in
                    cardController.showMysteryLabelOnFaceDown(true)
                    cardController.setFaceUp(value: false, animated: true)
                })
            }
            )
        }
    }


    // MARK: - Play animation for ShowingNewUnlockedImage
    private func animateShowingNewUnlockedImage(image:ImageName) {
        let cellsViews = fictiveGametable.cells
        let locations = fictiveGametable.matrixSize.getLocationsInNaturalOrder(requestedCount: allControllers.count)
        
        // step 1 - Setting up all cards
        for cardControllerIndexValue in allControllers.enumerated() {
            if let location = locations[safelyIndex: cardControllerIndexValue.offset]
                , let cell = cellsViews[location]
            {
                let cardController = cardControllerIndexValue.element
                
                if newUnlockedImagesControllers.contains(cardController) {
                    newUnlockedImageCardContainer.addSubview(cardController.view)
                } else {
                    fictiveGametable.addSubview(cardController.view)
                }
                
                cell.setContraints(toLookLike: cardController.view)
                cardController.showMysteryLabelOnFaceDown(true)
                cardController.isVisible = true
                
                if unlockedImagesControllers.contains(where: { $0 == cardControllerIndexValue.element }) {
                    cardControllerIndexValue.element.setFaceUp(value: true, animated: false)
                }
            }
        }
        self.view.layoutIfNeeded()
        
        
        // Step 2 - Launching animation of the new unlocked image card
        DispatchQueue.main.asyncAfter(deadline: .now() + 1
                                      , execute: {
            self.newUnlockedImagesControllers.forEach{
                self.animateFacingUpAndZoomingNewUnlockedImage($0)
            }
        }
        )
    }

    private func animateFacingUpAndZoomingNewUnlockedImage(_ cardController:PresentationCardViewController) {
        let particlesImages = ParticlesLibraryViewModel.HappyFaces.Yellow.UIImages + ParticlesLibraryViewModel.Stars.Yellow.UIImages
        let vfxParticles = VfxParticlesExplosionViewController(numberOfParticles: UIParameter.RewardNewUnlockedImageParticles
                                                               , particlesImages: particlesImages
                                                               , duration: UIParameter.RewardNewUnlockedImageAnimationDuration
                                                               , maximumDelayByParticle: UIParameter.RewardNewUnlockedImageAnimationDuration / 2
                                                               , delay: 0
                                                               , completion: {
            [weak self] _ in
            cardController.setFaceUp(value: true
                                     , animated: true
                                     , completion: { _ in  })
            if let self {
                UIView.animate(withDuration: CardView.UIParameter.SetFaceUpAnimationDuration * 3
                               , animations: {
                    self.resetConstraints(of: cardController
                                          , toLookLike: self.newUnlockedImageCardContainer)
                    self.fictiveGametable.alpha = UIParameter.RewardNewUnlockedImageOtherImagesAlpha
                    self.view.layoutIfNeeded()
                }
                               , completion: {
                    _ in
                    self.closeButton.isHidden = false
                }
                )
            }
        }
        )
        let vfxBouncing = VfxBouncingViewController(viewToMakeBounce: cardController.view
                                                    , duration: UIParameter.RewardNewUnlockedImageAnimationDuration
                                                    , delay: 0)
        if let containerView = view
            , let vfxView = vfxParticles.view
        {
            self.addChild(vfxParticles)
            
            containerView.addSubview(vfxView)
            vfxView.translatesAutoresizingMaskIntoConstraints = false
            vfxView.setContraints(toLookLike: cardController.view, scaleBy: 2)
            
            vfxParticles.didMove(toParent: self)
            containerView.layoutIfNeeded()
            vfxBouncing.startAnimation()
            vfxParticles.startAnimation()
        }
        
        cardController.showMysteryLabelOnFaceDown(false)
        cardController.isVisible = true
    }
    
    @IBOutlet weak var newUnlockedImageCardContainer: UIView!
    
    
    // MARK: - Device rotations (traitCollection / SizeClass changes)
    private var lastOrientation = UIInterfaceOrientation.current
    private var lastVerticalSizeClass = UIScreen.main.traitCollection.verticalSizeClass

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        let newOrientation = UIInterfaceOrientation.current
        let newVerticalSizeClass = UIScreen.main.traitCollection.verticalSizeClass
        
        if newVerticalSizeClass != lastVerticalSizeClass {
            let orientationChange = newOrientation.changeHappened(since: lastOrientation)
            switch (orientationChange) {
            case .HalfTurn:
                fictiveGametable.rotateMatrix(clockwise: true)
                fictiveGametable.rotateMatrix(clockwise: true)
            case .TurnedClockwise:
                fictiveGametable.rotateMatrix(clockwise: true)
            case .TurnedCounterClockwise:
                fictiveGametable.rotateMatrix(clockwise: false)
            default:
                return
            }
            
            
            UIView.animate(withDuration: UIParameter.DeviceRotationAnimationDuration
                           , animations: {
                self.view.layoutIfNeeded()
            }
            )
        }
        lastOrientation = newOrientation
        lastVerticalSizeClass = newVerticalSizeClass
    }
    
}

extension SafeboxViewController {
    struct UIDesign {
        static let StoryboardName = "Safebox"
        static let StoryboardId = "SafeboxViewController"
    }
    
    struct UIParameter {
        static let AnimationInitialDelay : TimeInterval = 1
        static let DeviceRotationAnimationDuration : TimeInterval = 1
        
        static let RewardNewUnlockedImageAnimationDuration : TimeInterval = 3
        static let RewardNewUnlockedImageParticles = 25
        static let RewardNewUnlockedImageOtherImagesAlpha = 0.3
    }
}
