//
//  StagesCollectionViewCell.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 23/02/2024.
//

import UIKit

protocol StagesCollectionViewCellDelegate {
    func unactivateCellForInteraction()
}

class StagesCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    static var BackgroundColor : UIColor = .white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        updateView()
    }
    
    // MARK: - State (UI configuration) of the cell
    enum State { case Activated, WaitingForActivation, OtherCellIsActivated }
    var state : State = .WaitingForActivation {
        didSet {
            if oldValue != state {
                UIView.animate(withDuration: UIParameter.StateUpdateAnimationDuration
                               , animations: { self.updateView() } )
            }
        }
    }
    
    private func updateView() {
        cellBackground.backgroundColor = Self.BackgroundColor
        
        switch(state) {
        case .Activated:
            longPressGestureInterceptor.isEnabled = true
            zoomableContentConstraintWidth.constant = 0
            zoomableContentConstraintHeight.constant = 0
            cardsExamplesContainersStack.alignment = .center
            layoutIfNeeded()
            
            levelsCollectionUserInteractionsInterceptor.isHidden = true
            cellBackground.alpha = UIParameter.StateActivated.BackgroundAlpha
            levelsCollectionContainer.alpha = UIParameter.StateActivated.LevelsCollectionContainerAlpha
            closeButton.alpha = 1
            
        case .WaitingForActivation, .OtherCellIsActivated:
            longPressGestureInterceptor.isEnabled = false
            
            zoomableContentConstraintWidth.constant = zoomableContentConstraintWidthConstantInitialValue
            zoomableContentConstraintHeight.constant = zoomableContentConstraintHeightConstantInitialValue
            cardsExamplesContainersStack.alignment = .top
            layoutIfNeeded()
            
            levelsCollectionUserInteractionsInterceptor.isHidden = false
            cellBackground.alpha = UIParameter.StateNotActivated.BackgroundAlpha
            levelsCollectionContainer.alpha = UIParameter.StateNotActivated.LevelsCollectionContainerAlpha
            closeButton.alpha = 0
        }
        
        switch(state) {
        case .OtherCellIsActivated:
            zoomableContent.alpha = UIParameter.StateOtherCellIsActivated.SelfAlpha
        case .Activated, .WaitingForActivation:
            zoomableContent.alpha = UIParameter.StateNotOtherCellIsActivated.SelfAlpha
        }
    }

    
    // MARK: - Gestures
    private lazy var longPressGestureInterceptor : UILongPressGestureRecognizer = {
        let result = UILongPressGestureRecognizer()
        result.delegate = self
        result.minimumPressDuration = 0
        result.isEnabled = false
        result.cancelsTouchesInView = false     // necessary for the tap on a cell in sub collection view to work, and also the close button
        addGestureRecognizer(result)
        return result
    }()

    
    // The longPressGestureInterceptor allows gestures of this cell to be executed but blocks the other ones (of the parent collection view)
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool
    {
        return (otherGestureRecognizer.view?.isDescendant(of: self) == false)
    }
    
    // The longPressGestureInterceptor must allow other gestures to work otherwise sub collection view will not scroll
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool 
    {
        return true
    }
    
    @IBOutlet weak var cellBackground: RoundedShadowedView! {
        didSet {
            cellBackground.alpha = UIParameter.StateNotActivated.BackgroundAlpha
            cellBackground.cornerRadius = UIParameter.CornerRadius
            cellBackground.shadowRadius = UIParameter.Shadow.Radius
            cellBackground.shadowOpacity = UIParameter.Shadow.Opacity
            cellBackground.shadowColor = UIParameter.Shadow.Color
            
        }
    }
    @IBOutlet weak var cellContent: UIView! {
        didSet {
            // prevent animated levels cells (which gets bigger) to appears out of the cellBackground and its rounded corners
            cellContent.layer.cornerRadius = UIParameter.CornerRadius
        }
    }
    
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var zoomableContent: UIView!
    @IBOutlet weak var cardsExamplesContainersStack: UIStackView!
    @IBOutlet weak var levelsCollectionContainer: UIView! {
        didSet {
            levelsCollectionContainer.alpha = UIParameter.StateNotActivated.LevelsCollectionContainerAlpha
        }
    }
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.alpha = 0
        }
    }
    
    @IBAction func closeButtonTapAction() {
        delegate?.unactivateCellForInteraction()
    }
    
    var delegate : StagesCollectionViewCellDelegate?
    
    @IBOutlet weak var levelsCollectionUserInteractionsInterceptor: UIView!
    private var zoomableContentConstraintWidthConstantInitialValue : CGFloat!
    @IBOutlet weak var zoomableContentConstraintWidth: NSLayoutConstraint! {
        didSet {
            zoomableContentConstraintWidthConstantInitialValue = zoomableContentConstraintWidth.constant
        }
    }
    private var zoomableContentConstraintHeightConstantInitialValue : CGFloat!
    @IBOutlet weak var zoomableContentConstraintHeight: NSLayoutConstraint! {
       didSet {
           zoomableContentConstraintHeightConstantInitialValue = zoomableContentConstraintHeight.constant
       }
   }
    @IBOutlet weak var examplesCardsStackConstraintHeight: NSLayoutConstraint!

}

extension StagesCollectionViewCell {
    struct UIParameter {
        struct StateActivated {
            static let BackgroundAlpha : CGFloat = 0.9
            static let LevelsCollectionContainerAlpha : CGFloat = 1
        }
        struct StateNotActivated {
            static let BackgroundAlpha : CGFloat = 0.7
            static let LevelsCollectionContainerAlpha : CGFloat = 0.5
        }
        
        struct StateOtherCellIsActivated {
            static let SelfAlpha : CGFloat = 0.5
        }
        struct StateNotOtherCellIsActivated {
            static let SelfAlpha : CGFloat = 1
        }
        static let CornerRadius : CGFloat = 14
        static let StateUpdateAnimationDuration : TimeInterval = 0.25
        
        struct Shadow {
            static let Radius : CGFloat = 20
            static let Opacity : Float = 1
            static let Color : CGColor = UIColor.black.cgColor
        }
    }
}
