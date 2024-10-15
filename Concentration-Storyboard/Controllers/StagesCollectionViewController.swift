//
//  StagesCollectionViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 23/02/2024.
//

import UIKit

class StagesCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate
{
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGestureRecognizer.addTarget(self, action: #selector(collectionViewLongPressAction))
        collectionView.addGestureRecognizer(longPressGestureRecognizer)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    
    // MARK: - Gesture handling

    // This gesture give the ability to detect any scrolling on the collection view, to unactivate the current activated cell when the touch occurs outside this cell
    // This gesture will be disabled by a prioritary custom gesture defined on activated cell, when touches occurs inside this cell
    private lazy var longPressGestureRecognizer : UILongPressGestureRecognizer = {
        let result = UILongPressGestureRecognizer()
        result.delegate = self
        result.minimumPressDuration = 0
        result.cancelsTouchesInView = false
        return result
    }()
    
    @objc func collectionViewLongPressAction() {
        if cellActivatedForInteraction != nil {
            self.cellActivatedForInteraction = nil
        }
    }
    
    // This function must return true to allow collection view to work properly
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool
    {
        return true
    }


    // MARK: - Device rotations
    @objc func onOrientationChange(_ notification:NSNotification) {
        if let cellActivatedForInteraction
            , let stageKey = cellActivatedForInteraction.levelsCollectionController.stageKey
        {
            collectionView.selectItem(at: indexPath(for: stageKey)
                                      , animated: true
                                      , scrollPosition: .centeredVertically)
            collectionView.visibleCells.forEach{ configure(appearanceOf: $0) }
        }
    }

    
    // MARK: - ViewModel / Data connexion
    var viewModel : LevelsLibraryViewModel? {
        didSet {
            updateFromModel()
        }
    }
    
    private func updateFromModel() {
        guard let viewModel else { return }
        
        for stageKey in viewModel.stages.keys {
            let levelsOfStage = viewModel
                .levels
                .values
                .filter{ $0.key.stage == stageKey }
                .sorted(by: { $0.key.level < $1.key.level })
            
            let vc : LevelsCollectionViewController
            if let existingVC = levelsCollectionControllers[stageKey] {
                vc = existingVC
            } else {
                vc = createNewLevelsCollectionViewController()
                levelsCollectionControllers[stageKey] = vc
            }
            
            vc.viewModel = levelsOfStage
        }
    }

    private func stageKey(for index:IndexPath) -> StageKey {
        index.item
    }
    private func indexPath(for stageKey:StageKey) -> IndexPath {
        IndexPath(item: stageKey, section: 0)
    }
    

    // MARK: - UICollectionViewDataSource base implementation
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.stages.count ?? 0
    }

    // MARK: - Cells configuration
    override func collectionView(_ collectionView: UICollectionView
                                 , cellForItemAt indexPath: IndexPath) -> UICollectionViewCell 
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UIDesign.CellIdentifier, for: indexPath)
        (cell as? StagesCollectionViewCell)?.delegate = self
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView
                                 , willDisplay cell: UICollectionViewCell
                                 , forItemAt indexPath: IndexPath) 
    {
        let stageKey = stageKey(for: indexPath)
        
        if let stageCell = cell as? StagesCollectionViewCell
            , let viewModel
            , let levelsCollectionController = levelsCollectionControllers[stageKey]
        {
            
            configure(appearanceOf: stageCell)
            
            configure(contentsOf: stageCell
                      , stageKey: stageKey
                      , fromCardsExamples: viewModel.stages[stageKey]?.generateCardsExamples() ?? [[]])
            
            configure(contentsOf: stageCell
                      , withController: levelsCollectionController)
        }
    }
    
    
    private func configure(appearanceOf cell: UICollectionViewCell) {
        guard let cell = (cell as? StagesCollectionViewCell) else { return }
        
        if let cellActivatedForInteraction {
            if cellActivatedForInteraction.cell != cell {
                cell.state = .OtherCellIsActivated
            } else {
                cell.state = .Activated
            }
        } else {
            cell.state = .WaitingForActivation
        }
    }
    
    private func configure(contentsOf stageCell:StagesCollectionViewCell
                           , stageKey:StageKey
                           , fromCardsExamples cardsExamples:[StageViewModel.CardExample])
    {
        stageCell.cardsExamplesContainersStack.subviews.forEach{ $0.isHidden = true }
        stageCell.cardsExamplesContainersStack.isHidden = false
        
        for cardExampleKV in cardsExamples.enumerated() {
            
            let cardExampleContainer : UIView
            if stageCell.cardsExamplesContainersStack.subviews.indices.contains(cardExampleKV.offset) {
                cardExampleContainer = stageCell.cardsExamplesContainersStack.subviews[cardExampleKV.offset]
            } else {
                cardExampleContainer = UIView()
                stageCell.cardsExamplesContainersStack.addArrangedSubview(cardExampleContainer)
            }
            
            var cardExampleControllers : [PresentationCardViewController]
            if let existingControllers = cardsExamplesControllers[stageKey]?[cardExampleKV.offset] {
                configureCardExampleControllers(existingControllers, asSubviewOf: cardExampleContainer)
                cardExampleControllers = existingControllers
            } else {
                cardExampleControllers = addNewCardExampleControllers(cardExampleKV.element.count
                                                                   , for: stageKey
                                                                   , and: cardExampleKV.offset
                                                                   , in: cardExampleContainer)
            }
            
            cardExampleContainer.isHidden = false
            cardExampleContainer.layoutIfNeeded()
            cardExampleControllers.forEach{ $0.setFaceUp(value: false, animated: false) }
            
            var cardCounter = 0
            cardExampleControllers.forEach{
                cardVC in
                cardVC.viewModel = (key:0
                                    , value:cardExampleKV.element.first!)
                DispatchQueue.main.asyncAfter(deadline: .now() + UIParameter.CardsExamplesFacingAnimationDelay + 0.33*Double(cardExampleKV.offset) + 0.25*Double(cardCounter)) {
                    [weak cardVC] in
                    cardVC?.setFaceUp(value: true, animated: true)
                }
                
                cardCounter += 1
            }
            cardExampleContainer.isHidden = false
        }
    }
    
    private func configure(contentsOf stageCell:StagesCollectionViewCell
                           , withController levelsCollectionController: LevelsCollectionViewController)
    {
        guard let containerView = stageCell.levelsCollectionContainer else { return }
        containerView.subviews.forEach{ $0.removeFromSuperview() }
        containerView.addSubviewFullsized(levelsCollectionController.view)
    }

    // MARK: - Child PresentationCardViewControllers
    typealias CardExampleKey = Int
    private var cardsExamplesControllers : [StageKey:[CardExampleKey:[PresentationCardViewController]]] = [:]
    
    private func addNewCardExampleControllers(_ cardsInContainer:Int
                                              , for stageKey:StageKey
                                              , and cardExampleKey:CardExampleKey
                                              , in container: UIView) -> [PresentationCardViewController]
    {
        var result = [PresentationCardViewController]()
        
        for _ in 0..<cardsInContainer {
            let newCardViewController = PresentationCardViewController()
            addChild(newCardViewController)
            
            result.append(newCardViewController)
        }
        configureCardExampleControllers(result, asSubviewOf: container)
        result.forEach{
            $0.didMove(toParent: self)
            $0.isVisible = true
        }
        
        if !cardsExamplesControllers.keys.contains(stageKey) {
            cardsExamplesControllers[stageKey] = [:]
        }
        cardsExamplesControllers[stageKey]![cardExampleKey] = result
        return result
    }
    
    private func configureCardExampleControllers(_ cardControllers:[PresentationCardViewController]
                                                 , asSubviewOf container:UIView)
    {
        container.subviews.forEach{
            $0.removeFromSuperview()
        }
        
        let numberOfCards = cardControllers.count
        let scalingFactor : CGFloat = 2/4 + ((1 / CGFloat(numberOfCards)) * 2/4)
        let scalingFactorStep = (1-scalingFactor)*2 / CGFloat(numberOfCards-1)
        
        for index in 0..<numberOfCards {
            if let cardView = cardControllers[index].view {
//                NSLayoutConstraint.deactivate(cardView.constraints)
                cardView.removeFromSuperview()
                container.addSubview(cardView)
                let offsetFactor = scalingFactor + (CGFloat(index)*scalingFactorStep)
                let constraints = [
                    cardView.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: scalingFactor)
                    ,cardView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: scalingFactor)
                    ,NSLayoutConstraint(item: cardView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: offsetFactor, constant: 0)
                    ,NSLayoutConstraint(item: cardView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: offsetFactor, constant: 0)
                ]
                NSLayoutConstraint.activate(constraints)
            }
        }
    }

    // MARK: - Child LevelsCollectionViewControllers
    private var levelsCollectionControllers : [StageKey:LevelsCollectionViewController] = [:]


    func createNewLevelsCollectionViewController() -> LevelsCollectionViewController {
        let sb = UIStoryboard(name: LevelsCollectionViewController.UIDesign.StoryboardName, bundle: nil)
        let vc = sb.instantiateInitialViewController() {
            coder in
            let vc = LevelsCollectionViewController(coder: coder)
            return vc
        } as! LevelsCollectionViewController
        
        vc.delegate = self
        addChild(vc)

        let view = vc.view!
        view.translatesAutoresizingMaskIntoConstraints = false
        vc.didMove(toParent: self)
        
        return vc
    }
    
    
    // MARK: - CollectionView enhancements
    @discardableResult
    private func scrollAndSelectCell(for levelKey:LevelKey) -> LevelsCollectionViewCell? {
        let stageIndexPath = indexPath(for: levelKey.stage)
        
        // select item in the stages collection
        collectionView.selectItem(at: stageIndexPath
                                  , animated: true
                                  , scrollPosition: .centeredVertically)
        // call didSelectItem to perform usual operations when activating a cell
        collectionView(collectionView
                       , didSelectItemAt: stageIndexPath)
        
        // select item in the sub collection of levels
        self.levelsCollectionControllers[levelKey.stage]?
            .collectionView
            .selectItem(at: IndexPath(item: levelKey.level, section: 0)
                        , animated: true
                        , scrollPosition: .centeredHorizontally)
        
        let levelCell = self.levelsCollectionControllers[levelKey.stage]?
            .collectionView
            .cellForItem(at: IndexPath(item: levelKey.level, section: 0)) as? LevelsCollectionViewCell
        
        return levelCell
    }

    // MARK: - Handling activation/unactivation of a stage cell
    var cellActivatedForInteraction : (cell:StagesCollectionViewCell
                                       , levelsCollectionController:LevelsCollectionViewController)? = nil {
        didSet {
            
            if let oldValue = oldValue {
                oldValue.levelsCollectionController.activatedForInteraction = false
            }
            
            if let newValue = cellActivatedForInteraction {
                newValue.levelsCollectionController.activatedForInteraction = true
//                newValue.levelsCollectionController.scrollToFirstLevelToPlay()
            }
            
            collectionView.visibleCells.forEach{ configure(appearanceOf: $0) }
        }
    }

    override func collectionView(_ collectionView: UICollectionView
                                 , didSelectItemAt indexPath: IndexPath)
    {
        let cell = collectionView.cellForItem(at: indexPath)
        let stageKey = stageKey(for: indexPath)
        
        if let cell = cell as? StagesCollectionViewCell
            , let levelsCollectionController = levelsCollectionControllers[stageKey]
        {
            if let cellActivatedForInteraction, cellActivatedForInteraction.cell != cell {
                self.cellActivatedForInteraction = nil
            }
            
            let cellActivated = !levelsCollectionController.activatedForInteraction
            
            if cellActivated {
                collectionView.selectItem(at: indexPath
                                          , animated: true
                                          , scrollPosition: .centeredVertically)
                cellActivatedForInteraction = (cell: cell
                                               , levelsCollectionController: levelsCollectionController)
            }
        }
    }

    // MARK: - Level Controller launching and closing
    private weak var levelLaunched : LevelViewController?
    private weak var endOfGameLaunched : EndOfGameViewController?
    
    private func closePreviousLevelController(completion : (() -> Void)? = nil) {
        if let endOfGameLaunched {
            endOfGameLaunched.dismiss(animated: false, completion: {
                self.endOfGameLaunched = nil
                self.closePreviousLevelController(completion: completion)
            }
            )
        }
        else if let levelLaunched {
            levelLaunched.dismiss(animated: true, completion: {
                self.levelLaunched = nil
                self.closePreviousLevelController(completion: completion)
            }
            )
        } else {
            completion?()
        }
    }
    
    enum LaunchLevelOption { case LaunchDirectly, AnimateCell, ScrollToCellAndAnimateCell }
    private func launchLevel(_ givenLevel:LevelViewModelProtocol
                             , do option:LaunchLevelOption = .ScrollToCellAndAnimateCell)
    {
        var level = givenLevel

        // UI actions if requested - scrolling and animation to the level-to-launch corresponding cell
        var delayBeforeLaunchingLevel : TimeInterval = 0
        
        switch(option) {
        case .ScrollToCellAndAnimateCell:
            
            let levelCell = scrollAndSelectCell(for: level.key)
            delayBeforeLaunchingLevel += UIParameter.ScrollToCellAnimationDuration
            
            delayBeforeLaunchingLevel += LevelsCollectionViewCell.UIParameter.TapUnlockedAnimationDuration
            DispatchQueue.main.asyncAfter(deadline: .now() + UIParameter.ScrollToCellAnimationDuration) {
                levelCell?.animateTapAction()
            }
            
        case .AnimateCell:
 
            let levelCell = self
                .levelsCollectionControllers[level.key.stage]?
                .collectionView
                .cellForItem(at: IndexPath(item: level.key.level, section: 0)) as? LevelsCollectionViewCell
            
            delayBeforeLaunchingLevel += LevelsCollectionViewCell.UIParameter.TapUnlockedAnimationDuration
            
            levelCell?.animateTapAction()

        default:
            break
        }
        
        // Launching Level in a new View Controller
        if level.state.unlocked {
            level.startNewGame()
                
            let sb = UIStoryboard(name: LevelViewController.UIDesign.StoryboardName, bundle: nil)
            let vc = sb.instantiateViewController(identifier: LevelViewController.UIDesign.StoryboardId
                                                  ,creator: {
                coder in
                
                return LevelViewController(level: level
                                           , delegate: self
                                           , coder: coder)
            })
            
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            

            DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeLaunchingLevel) {
                self.levelLaunched = vc
                self.present(vc, animated: true)
            }
        }
    }
    

}

extension StagesCollectionViewController : StagesCollectionViewCellDelegate 
{
    func unactivateCellForInteraction() {
        cellActivatedForInteraction = nil
    }
}

extension StagesCollectionViewController : LevelsCollectionViewControllerDelegate 
{
    func startLevel(_ levelKey: LevelKey) {
        if let viewModel, let levelToLaunch = viewModel.levels[levelKey] {
            closePreviousLevelController() { self.launchLevel(levelToLaunch, do: .AnimateCell) }
        }
    }
}

extension StagesCollectionViewController : LevelViewControllerDelegate
{
    func createEndOfGameViewController(levelKey: LevelKey
                                       , withFinalScore finalScore: GameScoreModelProtocol
                                       , sender: LevelViewController) -> EndOfGameViewController?
    {
        if let viewModel
            , let endOfGame = viewModel.processEndOfGame(of: levelKey, withFinalScore: finalScore)
        {
            updateFromModel()
            
            let sb = UIStoryboard(name: EndOfGameViewController.UIDesign.StoryboardName, bundle: nil)
            let vc = sb.instantiateViewController(identifier: EndOfGameViewController.UIDesign.IdentifierInStoryboard
                                                  , creator: {
                coder in
                let vc = EndOfGameViewController(coder:coder)
                vc?.viewModel = endOfGame
                vc?.delegate = self
                return vc
            }) as? EndOfGameViewController
            
            if let vc {
                scrollAndSelectCell(for: levelKey)
                self.endOfGameLaunched = vc
                return vc
            }
        }
        return nil
    }
}

extension StagesCollectionViewController : EndOfGameViewControllerDelegate
{
    
    func restartLevel() {
        if let levelLaunched {
            closePreviousLevelController() { self.launchLevel(levelLaunched.viewModel, do: .AnimateCell) }
        }
    }
    
    func goToMenu() {
        closePreviousLevelController()
    }
    
    func startOtherLevel(_ levelKey: LevelKey) {
        if let viewModel, let levelToLaunch = viewModel.levels[levelKey] {
            closePreviousLevelController() { self.launchLevel(levelToLaunch ,do: .ScrollToCellAndAnimateCell) }
        }
    }
}

extension StagesCollectionViewController {
    struct UIParameter {
        static let ScrollToCellAnimationDuration : TimeInterval = 0.75
        static let CardsExamplesFacingAnimationDelay : TimeInterval = 0.5
    }
    struct UIDesign {
        static let StoryboardName = "Main"
        static let CellIdentifier = "StageCell"
        static let SegueLaunchGametableIdentifier = "launchGametable"
        static let LevelViewControllerIdentifier = "levelViewController"
    }
}

