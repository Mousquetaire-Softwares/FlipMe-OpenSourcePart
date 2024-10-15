//
//  CardViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 25/09/2023.
//

import UIKit


class PresentationCardViewController : UIViewController, CardViewControllerProtocol {
    
    init() {
        
        self.cardImageName = nil
        self.roundedAngleFactorAtCreation = 0
        super.init(nibName: nil, bundle: nil)
    }
    
    init(imageName: String? = nil
         ,roundedAngleFactorAtCreation:CGFloat = 0) {
        
        self.cardImageName = imageName
        self.roundedAngleFactorAtCreation = roundedAngleFactorAtCreation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    var viewModel:CardViewModel.KeyValue? = nil {
        didSet {
            if oldValue?.value != viewModel?.value {
                updateFromCardData()
            }
        }
    }
    let cardImageName:String?
    private var roundedAngleFactorAtCreation:CGFloat

    var vfxLauncherWhenNotAnimated: VfxLauncherProtocol? {
        didSet {
            // If there already is a vfxLauncher attributed to this VC, we disable its trigger so it will never be fired
            // aka the previous VFX is cancelled by the new one
            if let oldValue, let viewModel {
                oldValue.set(trigger: viewModel.key, value: false)
            }
            updateVfxLauncherWhenNotAnimated()
        }
    }
    private func updateVfxLauncherWhenNotAnimated() {
        if let viewModel, let vfxLauncherWhenNotAnimated {
            vfxLauncherWhenNotAnimated.set(trigger: viewModel.key, value: true)
        }
    }

 
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView = CardView()
        view = cardView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1))
        
        let randomAngle = CGFloat.random(in: 0..<(.pi/4))
        cardView.movingContentView.layer.transform = CATransform3DMakeRotation(randomAngle.roundToNearestStep(step: .pi/2, roundedValueToRealValueFactor: roundedAngleFactorAtCreation), 0, 0, 1)
        // Do any additional setup after loading the view.
        
        cardView.setCoverImage(imageName: CardViewModel.UIParameter.CoverImageDefault)
        self.updateFromCardData()
        if let cardImageName {
            cardView.setSingleCardImage(imageName: cardImageName)
        }
        cardView.setContentShadow(.WhenNotAnimated)
        self.updateView()
    }
    
    @IBOutlet var cardView: CardView!

   
    private var isMatched = false

    @IBInspectable
    public var isVisible:Bool = false {
        didSet { updateView() }
    }
    @IBInspectable
    private(set) var isFaceUp:Bool = false
    
    func setFaceUp(value: Bool, animated: Bool, completion: ((Bool) -> ())? = nil) {
        if isFaceUp != value {
            isFaceUp = value
            cardView.setFaceUp(isFaceUp
                               , action: animated ? .AnimateAndSwipeContentView(randomOrientation: false) : .DoNotAnimateAndSwipeContentView(randomOrientation: false)
                               , completion: completion)
        }
    }
    
    private func updateFromCardData() {
        if let viewModel {
            isMatched = viewModel.value.isMatched
            isFaceUp = viewModel.value.isFaceUp
            switch(viewModel.value.image) {
            case .Single(let imageName):
                cardView.setSingleCardImage(imageName: imageName)
            case .Double(let imageName1, let imageName2):
                cardView.setDoubleCardImage(imageName1: imageName1
                                            , imageName2: imageName2)
            }
            cardView.setCardImageBackground(viewModel.value.color)
        } else {
            cardView.setNoCardImage()
            cardView.setCardImageBackground(nil)        }
    }
    
    // MARK: - Look of the card view
    func rotate(clockwise:Bool) {
        cardView.rotate(clockwise: clockwise)
    }
    func setShadow(_ value:CardView.Shadow) {
        cardView.setContentShadow(value)
    }
    func showMysteryLabelOnFaceDown(_ value:Bool) {
        cardView.movingContentView.contentView.showMysteryLabel = value
    }
    
    private func updateView() {
        if isVisible {
            cardView.movingContentView.isHidden = false
        } else {
            cardView.movingContentView.isHidden = true
        }
        cardView.movingContentView.contentView.setNeedsDisplay()
    }
}



// MARK: - UI parameters
extension PresentationCardViewController {
    struct UIParameter {
        static let AnimationDurationShadowOff = 0.25
    }
}


// MARK: - General utilities
extension PresentationCardViewController {
    private func ratioToScreenSize(_ point:CGPoint) -> CGFloat {
        return point.distanceToOrigin / UIScreen.main.bounds.size.maxPoint.distanceToOrigin
    }
}
