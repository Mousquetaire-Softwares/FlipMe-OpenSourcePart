//
//  GameModeChooserViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 30/06/2023.
//

import UIKit

/// Layout in Storyboard :
/// - StagesCollectionVC is extended outside the screen to keep showing cells when scrolling.
///   There is an vertical offset (in collection view parameters) of 96 to keep a gap upside for the title. The same offset is defined at the bottom to make centering of a selected cell working properly
class GameModeChooserViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let randomBackground = BackgroundsLibraryModel.Shared.menuAvailableSet().randomElement() {
            background.image = UIImage(named: randomBackground.image)
            StagesCollectionViewCell.BackgroundColor = UIColor(cgColor:  randomBackground.color)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let tmpScore {
            let msg = UIAlertController(title: "Score", message: "\(Int(tmpScore*100))", preferredStyle: .alert)
            msg.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            }))
            self.present(msg, animated: true, completion: nil)
        }
    }
    
    // MARK: - Main UI Elements
    @IBOutlet weak var background: UIImageView! {
        didSet {
            background.alpha = LevelViewController.UIParameter.BackgroundImageAlpha
            background.contentMode = .scaleAspectFill
        }
    }
    
    // constraints outlets for Demo purposes only
    @IBOutlet weak var safeboxButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var helpButtonLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var safeboxButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Handling StagesCollection VC
    @IBOutlet weak var stagesCollectionContainer: UIView!
    private var stagesCollectionController : StagesCollectionViewController? {
        didSet {
            stagesCollectionController?.viewModel = gameLevelsLibrary
        }
    }
    
    @IBSegueAction func segueForStagesCollectionContainer(_ coder: NSCoder) -> StagesCollectionViewController? {
        stagesCollectionController = StagesCollectionViewController(coder: coder)
        return stagesCollectionController
    }
    
    
    // MARK: - Safebox features
    @IBOutlet weak var safeboxButton: UIButton!
    @IBAction func safeboxButtonTapAction(_ sender: Any) {
        presentSafebox()
    }
    @IBOutlet weak var safeboxContainer: UIView!
    
    private func presentSafebox() {
        let sb = UIStoryboard(name: SafeboxViewController.UIDesign.StoryboardName, bundle: nil)
        let vc = sb.instantiateViewController(identifier: SafeboxViewController.UIDesign.StoryboardId
                                              ,creator: {
            coder in
            return SafeboxViewController(ImagesLibraryModel.Shared
                                         , configuration: .ShowingContentWithRandomAnimation
                                         , coder: coder)
        })
            
        vc.modalPresentationStyle = .pageSheet
        vc.modalTransitionStyle = .coverVertical
        
        self.present(vc, animated: true)
        
    }
    
    // MARK: - General Helper
    @IBAction func helpButtonTapAction(_ sender: Any) {
        presentGeneralHelper()
    }
    
    private func presentGeneralHelper() {
        let vc = HelpAndCreditsViewController(nibName: nil, bundle: nil)
        
        vc.modalPresentationStyle = .pageSheet
        vc.modalTransitionStyle = .coverVertical
        
        self.present(vc, animated: true)
    }
    
    // MARK: Main gesture handling
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer
                           , shouldReceive touch: UITouch) -> Bool
    {
        touch.view?.isDescendant(of: stagesCollectionContainer) == false
    }
    

    @objc func backgroundTapAction(recognizer: UITapGestureRecognizer) {
//        stagesCollectionController?.cellActivatedForInteraction = nil
    }
    
    // MARK: ViewModel
    let gameLevelsLibrary = LevelsLibraryViewModel()
    private var tmpScore:Float?

    
    // MARK: External segues
    
    private var lastSeguedViewController: UIViewController?

    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        if let source = sender.source as? LevelViewController {
            if case .Playing(let engine) = source.viewModel.gameProcess
                , let score = (engine as? SinglePlayingViewModel)?.scoreEngine?.score
            {
                tmpScore = score.score
            }
        }
    }
}

extension GameModeChooserViewController {
    struct UIDesign {
        static let StoryboardName = "Main"
        static let SegueLaunchGametableIdentifier = "launchGametable"
        static let LevelViewControllerIdentifier = "levelViewController"
        
        struct GeneralHelper {
            static let StoryboardName = "HelpAndCredits"
        }
    }
    
    var SegueLaunchGametableIdentifier:String { UIDesign.SegueLaunchGametableIdentifier }
}

enum GameMode {
    case level(Int)
    case dynamic
}


