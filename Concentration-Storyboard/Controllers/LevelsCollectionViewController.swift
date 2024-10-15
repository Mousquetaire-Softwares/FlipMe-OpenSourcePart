//
//  LevelsCollectionViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 27/02/2024.
//

import UIKit

private let reuseIdentifier = "LevelCell"

protocol LevelsCollectionViewControllerDelegate : AnyObject {
    func startLevel(_:LevelKey)
}

class LevelsCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.isScrollEnabled = false
    }


    // MARK: - ViewModel / Data connexion
    private(set) var stageKey : StageKey?
    var viewModel : [LevelViewModelProtocol]? {
        didSet {
            updateFromViewModel()
        }
    }
    private func levelKey(for index:IndexPath) -> LevelKey? {
        if let stageKey {
            return LevelKey(stage: stageKey, level: index.item)
        } else {
            return nil
        }
    }
    private func indexPath(for levelKey:LevelKey) -> IndexPath {
        IndexPath(item: levelKey.level, section: 0)
    }
    

    
    weak var delegate : LevelsCollectionViewControllerDelegate?
    
    private func updateFromViewModel() {
        stageKey = viewModel?.first?.key.stage
        collectionView.reloadData()
    }
    
    func scrollToFirstLevelToPlay() {
        if let viewModel {
            let levelKeyToPlay : LevelKey?
            if let firstNotCompleted = viewModel.first(where: { $0.state.completed == false })?.key {
                levelKeyToPlay = firstNotCompleted
            } else if let lastUnlocked = viewModel.last(where: { $0.state.unlocked == true })?.key {
                    levelKeyToPlay = lastUnlocked
            } else {
                levelKeyToPlay = viewModel.first?.key
            }
            
            if let levelKeyToPlay {
                let pathToSelect = indexPath(for: levelKeyToPlay)
                self.collectionView
                    .selectItem(at: pathToSelect
                                , animated: true
                                , scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let viewModel
            , let cell = cell as? LevelsCollectionViewCell
        {
            let level = viewModel[indexPath.item]
            
            cell.state = {
                if level.state.unlocked {
                    if level.state.completed {
                        return .Restart
                    } else {
                        if level.state.points == 0 {
                            return .New
                        } else {
                            return .Play
                        }
                    }
                } else {
                    return .Locked
                }
            }()
            cell.numberOfCards = level.cardsToDeal
            if level.state.unlocked {
                if level.state.completed {
                    cell.progressionBarConfiguration = .Completed
                } else {
                    cell.progressionBarConfiguration = .Uncompleted(value: level.state.points
                                                                    , endOfBar: level.state.neededPointsToComplete)
                }
                cell.bestScoreRankView?.showRank(level.state.bestScore?.rank)
            } else {
                cell.progressionBarConfiguration = nil
                cell.bestScoreRankView?.showRank(nil)
            }
            cell.setContentNotVisible()
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? LevelsCollectionViewCell {
            cell.setContentVisible(animated: true)
        }
    }
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView
                                 , didSelectItemAt indexPath: IndexPath)
    {
//        let cell = collectionView.cellForItem(at: indexPath)
        
        if activatedForInteraction
            , let viewModel
            , viewModel.indices.contains(indexPath.item)
//            , let cell = cell as? LevelsCollectionViewCell
        {
            delegate?.startLevel(viewModel[indexPath.item].key)
        }
        
    }
    
    var activatedForInteraction = false {
        didSet {
            collectionView.isScrollEnabled = activatedForInteraction
        }
    }
    
    
}

extension LevelsCollectionViewController {
    struct UIDesign {
        static let StoryboardName = "LevelsCollectionViewController"
    }
    struct UIParameter {
        static let AnimationScaleFactor = 0.7
        static let AnimationDuration = 0.1
    }
}
