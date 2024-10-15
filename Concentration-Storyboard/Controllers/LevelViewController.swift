    //
    //  GameDynamicViewController.swift
    //  Concentration-Storyboard
    //
    //  Created by Steven Morin on 02/07/2023.
    //

import UIKit

enum LevelViewControllerError : Error {
    case ExpandGametable
}


class PlaceholderView : UIView { }

protocol LevelViewControllerDelegate {
    func createEndOfGameViewController(levelKey:LevelKey, withFinalScore:GameScoreModelProtocol, sender: LevelViewController) -> EndOfGameViewController?
}

class LevelViewController: UIViewController, CardsDealerViewControllerDelegate, HelperForSwipingViewControllerDelegate, GameProcessViewModelDelegate {
    
    init?(level:LevelViewModelProtocol
          , delegate : LevelViewControllerDelegate
          , coder:NSCoder) {
        
        self.viewModel = level
        self.delegate = delegate
        super.init(coder: coder)
        
//        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder:NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
    deinit {
//        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let backgroundImageName = BackgroundsLibraryModel.Shared.gametableAvailableSet().randomElement() {
            backgroundImage.image = UIImage(named: backgroundImageName)
        }
        
        animateUpdatingCardsPlaceholdersStructure(withDuration: 0)
        
        viewModel.delegate = self
        
        placeholdersOfMatchedCardsStack.subviews.forEach{ $0.removeFromSuperview() }
        
        if viewModel.userCanAddCards {
            cardsDealerContainerView.isUserInteractionEnabled = true
        } else {
            cardsDealerContainerView.isUserInteractionEnabled = false
            addCards(groupsOfMatchingCards: viewModel.cardsToDeal / viewModel.cardsByMatch)
        }
    }
    
    private var delegate : LevelViewControllerDelegate
    
    
    // MARK: - General UI elements & decorations
    @IBOutlet var gametableView: GametableView! {
        didSet {
            gametableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(gametableViewPanAction(sender:))))
        }
    }
    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = UIParameter.BackgroundImageAlpha
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubviewFullsized(imageView, at: 0)

        return imageView
    }()
    
    @IBOutlet weak var masterButton: UIButton!

    // constraints outlets for Demo purposes only
    @IBOutlet weak var masterButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var masterStackRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var masterStackLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var masterButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var levelMasterStackBottomConstraint: NSLayoutConstraint!
    
    
    // MARK: - Dependencies builders
    // CardVC
    internal lazy var cardViewControllerBuilder : (LevelViewController, Bool) -> CardViewController = {
        PlayableCardViewController(delegate: $0, staticOrientation: $1)
    }
    private func buildCardViewController() -> CardViewController {
        cardViewControllerBuilder(self, viewModel.staticOrientation)
    }

    
    
    // MARK: - Game ViewModel management
    // viewModels
    private(set) var viewModel : LevelViewModelProtocol
    
    private func setGamePlaying() {
        if !updateStructureInProcess {
            viewModel.setGamePlaying(shuffleCardsLocationsIfGameWasDealing: true)
            updateCardViewControllersAfterShuffle()
            fillPlaceholderOfMatchedCardsContainer()
        }
    }
    
    func gametableHasANewMatch(_: Set<CardViewModel.Key>) {
        //        <#code#>
    }
    
    func gametableCardsUpdated(_ keys: Set<CardViewModel.Key>) {
        if let gametable = viewModel.gameProcess.gametable {
            for key in keys {
                cardViewControllers[key]?.viewModel = gametable[key]
            }
        }
    }
    
    
    func gametableIsEmpty() {
        //        <#code#>
    }
    
    func gametableDeckIsEmpty() {
        cardsDealerContainerView.isUserInteractionEnabled = false
    }
    
    
    
    // MARK: - Gestures handling
    private var wrongTapCounter:Int = 0
    @objc func cardsViewsTapAction(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if wrongTapCounter < 2 {
                wrongTapCounter += 1
            } else {
                wrongTapCounter = 0
                showHelperForSwiping()
            }
        }
    }
    
    @objc public func gametableViewPanAction(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            hideHelperForSwiping()
        }
    }
    
    
    // MARK: - CardsViews Placeholders
    @IBOutlet weak var cardsPlaceholdersMasterStackView: UIStackView! {
        didSet {
            cardsPlaceholdersMasterStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardsViewsTapAction(sender:))))
        }
    }
    @IBOutlet var cardsPlaceholdersVerticalStackViews: [UIStackView]!
    private var cardsPlaceholdersSize : Size2D {
        return Size2D(rows: cardsPlaceholdersVerticalStackViews.first?.arrangedSubviews.count ?? 0
                      , columns: cardsPlaceholdersMasterStackView.arrangedSubviews.count)
    }
    func cardPlaceholder(at location:Location2D) -> UIView? {
        if cardsPlaceholdersVerticalStackViews.count > location.column
        {
            let verticalStackView = cardsPlaceholdersVerticalStackViews[location.column]
            if verticalStackView.arrangedSubviews.count > location.row {
                let placeholderView = verticalStackView.arrangedSubviews[location.row]
                return placeholderView
            }
        }
        return nil
    }
    
    
    
    // cardSize is used by card view controllers - it has to be updated manually only when animations that changes layout (so size of the cards) have ended
    private(set) lazy var cardSize: CGFloat = cardSizeCalculator()
    private lazy var cardSizeSecureDefaultValue: CGFloat = {
        cardsPlaceholdersVerticalStackViews.first?.bounds.width ?? cardsPlaceholdersMasterStackView.bounds.width
    }()
    private func cardSizeCalculator() -> CGFloat {
        cardViewControllers.values.first?.view.bounds.width ?? cardSizeSecureDefaultValue
    }
    private func updateCardSize() {
        cardSize = cardSizeCalculator()
    }
    
    
    // MARK: - CardViewControllers
    private var cardViewControllers : [CardViewModel.Key:CardViewController] = [:]
    @IBOutlet weak var cardsViewsContainerView: UIView! {
        didSet {
            cardsViewsContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardsViewsTapAction(sender:))))
        }
    }
    
    // special work to do in case of cards shuffling in gametable VM
    // we have to reassign cardsKeyValue to each CardViewController according to the *location* of the cardVC - which doesn't move - and the new location of the card VM - which have moved
    private func updateCardViewControllersAfterShuffle() {
        guard let gametable = viewModel.gameProcess.gametable else { return }
        var newCardViewControllers = [CardViewModel.Key:CardViewController]()
        var orphanCards = [CardViewModel.Key : CardViewModel]()
        
        for cardData in gametable.cards {
            let targetLocation = cardData.value.location
            if let cardPreviousKey = cardViewControllers.filter({ $0.value.viewModel?.value.location == targetLocation }).first?.key
                , let targetCardViewController = cardViewControllers[cardPreviousKey]
            {
                cardViewControllers.removeValue(forKey: cardPreviousKey)
                targetCardViewController.viewModel = cardData
                newCardViewControllers[cardData.key] = targetCardViewController
            } else {
                orphanCards[cardData.key] = cardData.value
            }
        }
        for cardData in orphanCards {
            if let (_, targetCardViewController) = cardViewControllers.popFirst() {
                targetCardViewController.viewModel = cardData
                newCardViewControllers[cardData.key] = targetCardViewController
            } else {
                cardsToAddInController.append(cardData)
            }
        }
        cardViewControllers = newCardViewControllers
        updateStructureIfNeeded()
    }
    
    
    private func createCardViewController(bindWith cardData:CardViewModel.KeyValue) -> CardViewController? {
        // Real card view creation - with controller
        let newCardViewController = buildCardViewController()
        cardViewControllers[cardData.key] = newCardViewController
        addChild(newCardViewController)
        
        let newCardView = newCardViewController.view!
        cardsViewsContainerView.addSubview(newCardView)
        newCardViewController.viewModel = cardData
        newCardViewController.didMove(toParent: self)
        
        return newCardViewController
    }
    
    
    
    
    // MARK: - Dealing cards : adding cards in viewModel and UI (animated)
    /// Adding cards, meaning, asking dealerVM to add cards and ask UI to update consequently
    func addCards() {
        addCards(groupsOfMatchingCards: 1)
    }
    func addCards(groupsOfMatchingCards : Int) {
        if case .Dealing = viewModel.gameProcess {
            groupsOfMatchingCardsToAddInViewModel += groupsOfMatchingCards
            self.updateStructureIfNeeded()
        }
    }
    
    
    private var groupsOfMatchingCardsToAddInViewModel = 0
    private var cardsToAddInController = [CardViewModel.KeyValue]()
    /// All new card views necessary, to match viewModel -- recursive function (for transitions when news cards appears on screen, one after another)
    private var updateStructureInProcess = false
    private func updateStructureIfNeeded() {
        guard updateStructureInProcess == false else { return }
        guard let gametable = viewModel.gameProcess.gametable else { return }
        updateStructureInProcess = true
        
        let animationDuration = 1/Double(cardsToAddInController.count + groupsOfMatchingCardsToAddInViewModel + 5)
        
        // case 1 : size of gametableVM is greater than UI
        if cardsPlaceholdersSize.columns < gametable.size.columns
            || cardsPlaceholdersSize.rows < gametable.size.rows
        {
            self.animateUpdatingCardsPlaceholdersStructure(withDuration: animationDuration / 2
                                                           ,completion: { finished in
                self.updateStructureInProcess = false
                self.updateStructureIfNeeded()
            })
        }
        // case 2 : there is cards in VM that need to be represented in UI (some CardVC are missing)
        else if !cardsToAddInController.isEmpty {
            let newCardToAddInController = cardsToAddInController.removeFirst()
            animateAddingCardView(newCardToAddInController
                                  ,withDuration: animationDuration
                                  ,completion: { finished in
                self.updateStructureInProcess = false
                self.updateStructureIfNeeded()
            })
        }
        // case 3 : UI is up to date, but we are Dealing and more cards need to be added in gametableVM
        else if case let .Dealing(dealerViewModel) = viewModel.gameProcess
                    , groupsOfMatchingCardsToAddInViewModel != 0
        {
            let remainingCardsToAdd = groupsOfMatchingCardsToAddInViewModel * dealerViewModel.gametable.cardsByMatch
            let cardsToAddInGametableView = remainingCardsToAdd - (gametableView.matrixSize.area - dealerViewModel.gametable.cards.count)
            let expandingDirection = gametableView.getExpandingDirection(remainingCardsToAdd: cardsToAddInGametableView)
            
            if let newCardsToAdd = try? dealerViewModel.addCardsInGametable(expandingDirection: expandingDirection) {
                cardsToAddInController.append(contentsOf: newCardsToAdd)
                addNewPlaceholderOfMatchedCards()
                groupsOfMatchingCardsToAddInViewModel -= 1
            } else {
                groupsOfMatchingCardsToAddInViewModel = 0
            }
            
            updateStructureInProcess = false
            self.updateStructureIfNeeded()
        }
        // case 4 : end of the job
        else {
            updateStructureInProcess = false
            if !viewModel.userCanAddCards {
                hideCardsDealerContainerView()
            }
        }
    }
    
    private func animateUpdatingCardsPlaceholdersStructure(withDuration duration: TimeInterval
                                                           , completion: ((Bool) -> Void)? = nil)
    {
        guard case .Dealing(let dealerViewModel) = viewModel.gameProcess else {
            return
        }
        while dealerViewModel.gametable.size.columns > cardsPlaceholdersSize.columns {
            let columnNum = cardsPlaceholdersSize.columns
            
            let newVerticalStackView = gametableView.configureNewVerticalStackView()
            newVerticalStackView.isUserInteractionEnabled = true
            cardsPlaceholdersMasterStackView.addArrangedSubview(newVerticalStackView)
            self.cardsPlaceholdersVerticalStackViews.append(newVerticalStackView)
            
            for _ in 0..<cardsPlaceholdersSize.rows {
                let newCardViewPlaceholder = PlaceholderView()
                newVerticalStackView.addArrangedSubview(newCardViewPlaceholder)
            }
            guard columnNum < cardsPlaceholdersSize.columns else { break }
        }
        while dealerViewModel.gametable.size.rows > cardsPlaceholdersSize.rows {
            let rowNum = cardsPlaceholdersSize.rows
            
            for columnNum in 0..<cardsPlaceholdersSize.columns {
                let newCardViewPlaceholder = PlaceholderView()
                cardsPlaceholdersVerticalStackViews[columnNum].addArrangedSubview(newCardViewPlaceholder)
            }
            guard rowNum < cardsPlaceholdersSize.rows else { break }
        }
        
        UIView.animate(withDuration: duration
                       ,delay: 0
                       ,options: [.curveEaseInOut]
                       ,animations: {
            self.view.layoutIfNeeded()
            self.updateCardSize()
        }
                       ,completion: completion
        )
        
    }
    
    private func animateAddingCardView(
        _ cardData : CardViewModel.KeyValue
        , withDuration duration: TimeInterval
        , completion: ((Bool) -> Void)? = nil
    ){
        self.cardsDealerViewController.addingCardsAnimation()
        
        guard let newCardVC = createCardViewController(bindWith: cardData) else { return }
        guard let viewToTransform = newCardVC.view else { return }
        
        view.layoutIfNeeded()
        
        let targetAffineTransform = CGAffineTransform.transform(
            view: viewToTransform
            ,toLookLike: cardsDealerContainerView.frame.zoom(by: CardsDealerViewController.UIParameter.CardViewToSquaredView)
            ,fromView: cardsDealerContainerView.superview
        )
        
        viewToTransform.transform = targetAffineTransform
        viewToTransform.layer.zPosition = 1
        newCardVC.isVisible = true
        
        UIView.animate(withDuration: duration
                       ,delay: 0
                       ,options: [.curveEaseInOut]
                       ,animations: {
            viewToTransform.transform = .identity
            viewToTransform.layer.zPosition = 0
        }
                       ,completion: completion
        )
        
    }
    
    
    // MARK: - CardsDealerViewController
    @IBOutlet weak var cardsDealerContainerView: UIView! {
        didSet {
            cardsDealerContainerView.addSubviewFullsized(cardsDealerViewController.view)
        }
    }
    
    private lazy var cardsDealerViewController = {
        let newVC = CardsDealerViewController()
        self.addChild(newVC)
        
        newVC.delegate = self
        newVC.didMove(toParent: self)
        return newVC
    }()
    
    private func hideCardsDealerContainerView() {
        self.cardsDealerContainerView.isHidden = true
    }
    
    
    // MARK: - Device rotations
    private var lastOrientation = UIInterfaceOrientation.current
    @objc func onOrientationChange(_ notification:NSNotification) {
        let newOrientation = UIInterfaceOrientation.current
        let orientationChange = newOrientation.changeHappened(since: lastOrientation)
        lastOrientation = newOrientation
        
        let rotationsClockwise : [Bool]
        switch (orientationChange) {
        case .HalfTurn:
            rotationsClockwise = [true,true]
        case .TurnedClockwise:
            rotationsClockwise = [true]
        case .TurnedCounterClockwise:
            rotationsClockwise = [false]
        default:
            return
        }
        
        rotationsClockwise.forEach{
            gametableView.rotateMatrix(clockwise: $0)
        }
        
        UIView.animate(withDuration: UIParameter.DeviceRotationAnimationDuration
                       , animations: {
            self.view.layoutIfNeeded()
            self.cardViewControllers.values.forEach{
                cardController in
                rotationsClockwise.forEach{
                    cardController.rotate(clockwise: $0)
                }
            }
        })
    }
    
    
    // MARK: - Matched cards & Success effect
    @IBOutlet weak var placeholdersOfMatchedCardsStack: UIStackView!
    private var placeholdersOfMatchedCardsIndices = [Int]()
    
    func addNewPlaceholderOfMatchedCards() {
        placeholdersOfMatchedCardsStack.addArrangedSubview(PlaceholderView())
        placeholdersOfMatchedCardsIndices.append(placeholdersOfMatchedCardsStack.subviews.endIndex - 1)
    }
    
    /// Adds more placeholders in their stackview if necessary
    /// The target is to have placeholders with a size of 2/3 of a perfect square, for matched cards to be visually stacked.
    /// If the current placeholder size is below, we do nothing
    func fillPlaceholderOfMatchedCardsContainer() {
        guard let firstPlaceholder = placeholdersOfMatchedCardsStack.subviews.first else { return }
        
        let placeholdersToAdd : Int
        if placeholdersOfMatchedCardsStack.axis == .horizontal {
            let targetWidth = firstPlaceholder.bounds.height * CGFloat(2.0/3)
            
            placeholdersToAdd = (Int(firstPlaceholder.bounds.width / targetWidth) - 1) * placeholdersOfMatchedCardsStack.subviews.count
        } else {
            let targetHeight = firstPlaceholder.bounds.width * CGFloat(2.0/3)
            
            placeholdersToAdd = (Int(firstPlaceholder.bounds.height / targetHeight) - 1) * placeholdersOfMatchedCardsStack.subviews.count
        }
        
        if placeholdersToAdd > 0 {
            for _ in 1...placeholdersToAdd {
                addNewPlaceholderOfMatchedCards()
            }
        }
    }
    
    /// Delivers Placeholder views from the end of the stack
    /// Uses an array of indices of placeholders to never give twice the same placeholder
    private func popPlaceholdersOfMatchedCards() -> PlaceholderView {
        if let index = placeholdersOfMatchedCardsIndices.popLast()
            , placeholdersOfMatchedCardsStack.subviews.indices.contains(index)
            , let placeholderView = placeholdersOfMatchedCardsStack.subviews[index] as? PlaceholderView
        {
            return placeholderView
        } else {
            if let firstPlaceholder = placeholdersOfMatchedCardsStack.subviews.filter({ ($0 as? PlaceholderView) != nil}).first as? PlaceholderView {
                return firstPlaceholder
            } else {
                let newPlaceholder = PlaceholderView()
                placeholdersOfMatchedCardsStack.addArrangedSubview(newPlaceholder)
                return newPlaceholder
            }
        }
    }
    
    private var matchedCardViewControllers : [[CardViewController]] = []
    
    func gametableRoundIsOver(playedKeys: Set<CardViewModel.Key>,scoreEffects: [ScoreEffectViewModel]) {
        guard let gametable = viewModel.gameProcess.gametable else { return }
        let cardsMatches = playedKeys.filter{ gametable[$0]?.value.isMatched == false }.isEmpty
        let playedCardVCs : [CardViewController] = Array(cardViewControllers.filter{ playedKeys.contains($0.key) }.values)
        
        let vfxLauncher : VfxLauncher
        let vfxBuilders : (UIViewController) -> [VfxViewController]
        
        if cardsMatches {
//            performFeedbackSuccess()
            
            matchedCardViewControllers.append(playedCardVCs)
            
            let freePlaceholderOfMatchedCards = popPlaceholdersOfMatchedCards()
            
            let endOfTheGame = (gametable.unmatchedCardsKeys.count == 0)
            
            let completion : ((Bool) -> ())?
            if endOfTheGame {
                completion = { [weak self] _ in self?.launchEndOfGame() }
            } else {
                completion = nil
            }
            
            vfxBuilders = {
                targetVC in
                var allVfx : [VfxViewController]
                
                allVfx = scoreEffects.map {
                    VfxParticlesExplosionViewController(numberOfParticles: $0.particlesQuantity
                                                        , particlesImages: $0.particlesImages
                                                        , duration: $0.animationDuration
                                                        , maximumDelayByParticle: $0.animationDuration / 2
                                                        , delay: 0)
                }
                allVfx.append(
                    VfxBouncingViewController(viewToMakeBounce: targetVC.view
                                              , duration: UIParameter.SuccessVfxBouncingDuration
                                              , delay: 0)
                )
                allVfx.append(
                    VfxMovingViewController(view: targetVC.view
                                            , targetView: freePlaceholderOfMatchedCards
                                            , mode: .ByNewConstraints(.KeepRatio(.BiggerThanTarget,.Bottom,.Right))
                                            , duration: UIParameter.SuccessVfxMovingDuration
                                            , delay: UIParameter.SuccessVfxBouncingDuration
                                            , completion: completion)
                )
                return allVfx
                
            }

        } else {
            vfxBuilders = {
                _ in
                scoreEffects.map {
                    VfxParticlesExplosionViewController(numberOfParticles: $0.particlesQuantity
                                                        , particlesImages: $0.particlesImages
                                                        , duration: $0.animationDuration
                                                        , maximumDelayByParticle: $0.animationDuration / 4
                                                        , delay: 0)
                }
            }
            
        }
        vfxLauncher = VfxLauncher(parent: self
                                  , triggers: Array(playedKeys)
                                  , targets: playedCardVCs
                                  , vfxBuildersFromTarget: vfxBuilders
                                  , vfxCaller: { $0.startAnimation(doNotDismissWhenFinished: false) })
        playedCardVCs.forEach{
            $0.vfxLauncherWhenNotAnimated = vfxLauncher
        }
    }

//    private func performFeedbackSuccess() {
//        let feedbackGenerator = UINotificationFeedbackGenerator()
//        feedbackGenerator.prepare()
//        feedbackGenerator.notificationOccurred(.success)
//    }
    
    // MARK: - End of the game
    private var endOfGameVfx : VfxEndOfGameViewController? = nil
    func launchEndOfGame() {
        guard endOfGameVfx == nil else { return }

        masterButton.isHidden = true
        
        let endOfGameVfx = VfxEndOfGameViewController(matchedCards:self.matchedCardViewControllers)
        self.endOfGameVfx = endOfGameVfx
        addChild(endOfGameVfx)
        view.addSubviewFullsized(endOfGameVfx.view)
        endOfGameVfx.didMove(toParent: self)
        view.layoutIfNeeded()
        let duration = endOfGameVfx.startSuccessAnimations()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            [weak self] in
            if let self
                , case let .Playing(playingEngine) = self.viewModel.gameProcess
                , let playingEngine = (playingEngine as? SinglePlayingViewModel)
                , let finalScore = playingEngine.scoreEngine?.score
                , let vc = self.delegate.createEndOfGameViewController(levelKey: self.viewModel.key
                                                                       , withFinalScore: finalScore
                                                                       , sender: self)
            {
                self.presentOnRoot(with: vc)
            } else {
                self?.masterButton.isHidden = false
            }
//            self?.performSegue(withIdentifier: UIDesign.EndOfGame.SegueId, sender: self)
        }
        
    }
    
    
    
    
    // MARK: - Helper for swiping integration
    private var helperForSwipingViewController:HelperForSwipingViewController?
    
    func randomImageNameInGametable() -> String? {
        if let randomCard = cardViewControllers
            .values
            .randomElement()?
            .viewModel?.value
        {
            switch(randomCard.image) {
            case .Single(let imageName):
                return imageName
            case .Double(let imageName1, _):
                return imageName1
            }
        } else {
            return nil
        }
    }
    
    func hideHelperForSwiping() {
        if let helperController = helperForSwipingViewController {
            helperController.willMove(toParent: nil)
            helperController.view.removeFromSuperview()
            helperController.removeFromParent()
            self.helperForSwipingViewController = nil
        }
    }
    func showHelperForSwiping() {
        if helperForSwipingViewController == nil {
            let storyboardName = "HelperForSwipingViewController"
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            
            let helperController = storyboard.instantiateInitialViewController(creator: { coder in
                HelperForSwipingViewController(delegate:self, coder: coder)
            })
            
            if let helperController, let helperView = helperController.view, let container = self.view {
                addChild(helperController)
                
                container.addSubview(helperView)
                helperView.translatesAutoresizingMaskIntoConstraints = false
                let height = min(container.bounds.width, container.bounds.height) * 0.8
                NSLayoutConstraint.activate([
                    helperView.widthAnchor.constraint(equalTo: helperView.heightAnchor, multiplier: 0.7)
                    ,helperView.heightAnchor.constraint(equalToConstant: height)
                    ,helperView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
                    ,helperView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
                ])
                helperController.didMove(toParent: self)
                helperForSwipingViewController = helperController
                //            }
            }
        }
    }
    
    
    
    // MARK: - Storyboard related
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showHelperForSwiping" {
            
        } else if segue.identifier == UIDesign.EndOfGame.SegueId {
//            if let vc = (segue.destination as? EndOfGameViewController)
//                , case let .Playing(playingEngine) = viewModel.gameProcess
//                , let playingEngine = (playingEngine as? SinglePlayingViewModel)
//                , let finalScore = playingEngine.scoreEngine?.score
//            {
//                delegate.endOfGame(levelKey: viewModel.key
//                                   , withFinalScore: finalScore)
//            }
        }
    }
    @IBSegueAction func segueEndOfGameInstantiation(_ coder: NSCoder) -> EndOfGameViewController? {
        let vc = EndOfGameViewController(coder:coder)
        return vc
    }
    
}




// MARK: CardViewDelegate implementation
extension LevelViewController : PlayableCardViewControllerDelegate {
    /// CardVC asks to face up card : asking the viewModel to do so
    /// returns : true if card has been faced up
    func faceUp(_ cardVC:CardViewController) -> Bool {
        wrongTapCounter = 0
        
        let result : Bool
        if self.groupsOfMatchingCardsToAddInViewModel > 0 {
            result = false
        } else {
            if case .Dealing = viewModel.gameProcess {
                setGamePlaying()
            }
            
            if case let .Playing(playingEngine) = viewModel.gameProcess,
               let key = cardVC.viewModel?.key
            {
                result = (try? playingEngine.faceUp(key)) != nil
            } else {
                result = false
            }
        }
        
        if result == true {
            hideCardsDealerContainerView()
        }
        return result
    }
    
    func putTwoUnmatchedCardsFaceDown() throws {
        if case let .Playing(playingEngine) = viewModel.gameProcess {
            try playingEngine.putUnmatchedCardsNotFaceUpIfRoundIsOver()
        }
    }
}

extension LevelViewController {
    // MARK: - Design values
    struct UIDesign {
        static let StoryboardName = "Main"
        static let StoryboardId = "levelViewController"
        struct EndOfGame {
            static let SegueId = "endOfGame"
        }
        
        static let CardsDealerWidthConstraintId = "cardsDealerWidthConstraint"
        static let NextMatchedCardTrailingConstraintId = "nextMatchedCardTrailingConstraint"
    }
    
    struct UIParameter {
        static let DeviceRotationAnimationDuration : TimeInterval = 1
        static let SuccessVfxBouncingDuration : TimeInterval = 0.5
        static let SuccessVfxMovingDuration : TimeInterval = 0.5
        static let BackgroundImageAlpha : CGFloat = 0.5
    }
}
