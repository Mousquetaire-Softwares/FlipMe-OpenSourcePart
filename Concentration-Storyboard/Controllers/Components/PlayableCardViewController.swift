//
//  CardViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 25/09/2023.
//

import UIKit

protocol PlayableCardViewControllerDelegate : AnyObject {
    func cardPlaceholder(at location:Location2D) -> UIView?
    func faceUp(_:any CardViewController) -> Bool
    func putTwoUnmatchedCardsFaceDown() throws
    func hideHelperForSwiping()
    var cardSize:CGFloat { get }
}


class PlayableCardViewController: UIViewController, CardViewControllerProtocol {
    
    init(delegate:PlayableCardViewControllerDelegate
         ,roundedAngleFactorAtCreation:CGFloat = UIParameter.RoundedAngleFactorAtCreationByDefault
         ,staticOrientation:Bool = false) {
        
        self.delegate = delegate
        self.cardImageNameOverride = nil
        self.roundedAngleFactorAtCreation = roundedAngleFactorAtCreation
        self.staticOrientation = staticOrientation
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
            if oldValue?.value.location != viewModel?.value.location {
                updateFromCardLocation()
            }
        }
    }
    weak var delegate : PlayableCardViewControllerDelegate?
    let cardImageNameOverride : String?
    private var roundedAngleFactorAtCreation : CGFloat
 
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
            vfxLauncherWhenNotAnimated.set(trigger: viewModel.key, value: !self.isAnimated)
        }
    }

 
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView = CardView()
        cardView.setFaceUp(false, action: .DoNotAnimate)
        view = cardView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(selfPanAction(recognizer:)))
        panGesture.maximumNumberOfTouches = 1
        cardView.addGestureRecognizer(panGesture)        
        
        let randomAngle = {
            if staticOrientation {
                return CGFloat.random(in: 0..<(.pi/4))
            } else {
                return CGFloat.random(in: 0...(.pi*2))
            }
        }()
        cardView.movingContentView.layer.transform = CATransform3DMakeRotation(randomAngle.roundToNearestStep(step: .pi/2, roundedValueToRealValueFactor: roundedAngleFactorAtCreation), 0, 0, 1)
        // Do any additional setup after loading the view.
        
        cardView.setCoverImage(imageName: CardViewModel.UIParameter.CoverImageDefault)
        self.updateFromCardData()
        if let cardImageNameOverride {
            cardView.setSingleCardImage(imageName: cardImageNameOverride)
        }
        self.updateView()
    }
    
    @IBOutlet var cardView: CardView!
    
    // MARK: - Card gameplay properties
    @IBInspectable
    public var isAnimated:Bool = false {
        didSet {
            if oldValue == true && isAnimated == false {
                UIView.animate(withDuration: UIParameter.AnimationDurationShadowOff
                               ,animations: { self.updateView() })
            } else {
                updateView()
            }
            updateVfxLauncherWhenNotAnimated()
        }
    }
   
    private var isMatched = false {
        didSet {
            cardView.isUserInteractionEnabled = !isMatched
        }
    }

    @IBInspectable
    public var isVisible:Bool = false {
        didSet { updateView() }
    }
    @IBInspectable
    private(set) var isFaceUp:Bool {
        get { cardView.isFaceUp }
        set {
            if cardView.isFaceUp == true && newValue == false {
                stopCurrentPanGestureIfExists = true
                cardView.setFaceUp(newValue
                                   , action:.AnimateAndSwipeContentView(randomOrientation: !staticOrientation))
            } else {
                cardView.setFaceUp(newValue
                                   , action:.DoNotAnimate)
            }
        }
    }
    
    
    func rotate(clockwise:Bool) {
        cardView.rotate(clockwise: clockwise)
    }
    func setShadow(_ value:CardView.Shadow) {
        cardView.setContentShadow(value)
    }
    func showMysteryLabelOnFaceDown(_ value:Bool) {
        cardView.movingContentView.contentView.showMysteryLabel = value
    }
    
    // MARK: - ViewModel links
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
    
    // MARK: - Position of the card in the gametable
    private var constraintsToPlaceholder = [NSLayoutConstraint]()
    private func updateFromCardLocation() {
        NSLayoutConstraint.deactivate(constraintsToPlaceholder)
        view.superview?.removeConstraints(constraintsToPlaceholder)
        constraintsToPlaceholder.removeAll()
        
        if let viewModel, let placeholderView = delegate?.cardPlaceholder(at: viewModel.value.location) {
            constraintsToPlaceholder =  [
                view.widthAnchor.constraint(equalTo: placeholderView.widthAnchor)
                ,view.heightAnchor.constraint(equalTo: placeholderView.heightAnchor)
                ,view.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor)
                ,view.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor)
            ]
            NSLayoutConstraint.activate(constraintsToPlaceholder)
        }
    }
    
    
    // MARK: - Look of the card view
    
    let staticOrientation : Bool
    
    private var contentIsZoomed = false
    var maximumZoomedCardSize : CGFloat {
        min(UIScreen.main.bounds.width,UIScreen.main.bounds.height) * CardView.UIParameter.MaximumZoomedCardSizeToScreenSize
    }
    var maximumZoomedSizeToRealSize : CGFloat {
        if let delegate, maximumZoomedCardSize > delegate.cardSize {
            return maximumZoomedCardSize / delegate.cardSize
        } else {
            return 1
        }
    }

    private func setupZoomedSize() {
        if case let scaleCardContentBy = maximumZoomedSizeToRealSize, scaleCardContentBy > 1 {
            cardView.setMovingContentScale(scaleCardContentBy)
            
            let transformScaling = CGFloat(1) / scaleCardContentBy
            cardView.movingContentView.layer.transform = CATransform3DScale(cardView.movingContentView.layer.transform
                                                                            , transformScaling
                                                                            , transformScaling
                                                                            , 1)
        }
        contentIsZoomed = true
    }
    
    private func updateView() {
        cardView.setContentShadow(isAnimated ? .WhenAnimated : .WhenNotAnimated)
        
        if isVisible {
            cardView.movingContentView.isHidden = false
        } else {
            cardView.movingContentView.isHidden = true
        }
        cardView.movingContentView.contentView.setNeedsDisplay()
    }
 
    
    // MARK: - Feedback notifications
    private var feedbackGenerator : UIImpactFeedbackGenerator? = nil
    
    // MARK: - Pan gesture handling
    struct CGFloat3d { var x,y,z : CGFloat }
    struct PanGestureStep {
        init(wasFacedUpBeforeGesture: Bool
             , layerTransformBeforeAnimation: CATransform3D
             , translation: CGPoint
             , velocity: CGPoint
             , previousStep:PanGestureStep?)
        {
            self.wasFacedUpBeforeGesture = wasFacedUpBeforeGesture
            self.layerTransformBeforeAnimation = layerTransformBeforeAnimation
            self.translation = translation
            self.velocity = velocity.distanceToOrigin
            self.maximumVelocity = max(self.velocity, previousStep?.maximumVelocity ?? 0)

            self.swipeVector = CGFloat3d(x: (-translation.y / max(translation.x.abs,translation.y.abs)).zeroIfNan
                                         ,y: (translation.x / max(translation.x.abs,translation.y.abs)).zeroIfNan
                                         ,z: 0 )
            self.significantTranslationDistance = Self.subjectiveSignificantTranslationDistance(between: translation, and: .zero)
            self.significantTranslationDistanceStep = Self.subjectiveSignificantTranslationDistance(between: translation, and: previousStep?.translation ?? .zero)
            self.rotationStep = {
                guard let previousStep = previousStep else {
                    return 0
                }
                if previousStep.translation == CGPoint.zero {
                    return 0
                } else {
                    return angleDifference(translation.angleToOrigin, previousStep.translation.angleToOrigin)
                }
            }()
            
            self.significantTranslationDistanceCumulated = (previousStep?.significantTranslationDistanceCumulated ?? .zero) + self.significantTranslationDistanceStep
        }
        
        let wasFacedUpBeforeGesture : Bool
        let layerTransformBeforeAnimation : CATransform3D
        let swipeVector : CGFloat3d

        let rotationStep : CGFloat
        let significantTranslationDistanceStep : CGFloat
        let significantTranslationDistance : CGFloat
        let translation : CGPoint
        let velocity : CGFloat
        let maximumVelocity : CGFloat
        
        var significantTranslationDistanceCumulated : CGFloat?
        var swipeFactor : CGFloat = 0
        var rotation : CGFloat = 0
        
        
        static func subjectiveSignificantTranslationDistance(between p1:CGPoint, and p2:CGPoint) -> CGFloat {
            max((p1.x-p2.x).abs , (p1.y-p2.y).abs)
        }
        
    }
    private var previousPanGestureStep : PanGestureStep?
    private var stopCurrentPanGestureIfExists = false
    @objc private func selfPanAction(recognizer: UIPanGestureRecognizer) {
        // previousPanStep is an essential object for handling pan gesture of the card
        // if the pan is a beginning gesture AND the card is not currently animated ( = isAnimated is false) THEN this object is set as the current state
        let previousPanStep:PanGestureStep?
        if recognizer.state == .began && self.isAnimated == false {
            previousPanStep = PanGestureStep(
                wasFacedUpBeforeGesture: self.isFaceUp
                ,layerTransformBeforeAnimation: cardView.movingContentView.layer.transform
                ,translation: .zero
                ,velocity: .zero
                ,previousStep: nil
            )
            delegate?.hideHelperForSwiping()
        } else {
            previousPanStep = self.previousPanGestureStep
        }
        
        guard let previousPanStep else { return }
        
        if stopCurrentPanGestureIfExists && recognizer.state == .began {
            stopCurrentPanGestureIfExists = false
        }
        // An existing pan gesture can be asked to be interrupted by code somewhere
        if stopCurrentPanGestureIfExists {
            recognizer.state = .cancelled
        }
        animateSwipingAndMoving(recognizer: recognizer
                                , previousPanStep:previousPanStep)
    }
    
    private func animateSwipingAndMoving(recognizer:UIPanGestureRecognizer, previousPanStep:PanGestureStep) {
        
        guard let cardSuperview = cardView.superview else { return }
        
        let endingAnimation : Bool
        let newPanStep : PanGestureStep
        
        if recognizer.state == .began {
            if self.isAnimated == false {
                
                
                if !self.isFaceUp {
                    if (try? delegate?.putTwoUnmatchedCardsFaceDown()) == nil {
                        recognizer.state = .cancelled
                        return
                    }
                }
                if !contentIsZoomed {
                    setupZoomedSize()
                }
                
                newPanStep = PanGestureStep(
                    wasFacedUpBeforeGesture: self.isFaceUp
                    ,layerTransformBeforeAnimation: cardView.movingContentView.layer.transform
                    ,translation: recognizer.translation(in: cardSuperview)
                    ,velocity: recognizer.velocity(in: cardSuperview)
                    ,previousStep: previousPanStep
                )
                
                self.isAnimated = true
                
                self.feedbackGenerator = UIImpactFeedbackGenerator(style: .medium )
                self.feedbackGenerator?.prepare()
                
                cardView.superview?.bringSubviewToFront(cardView)
            } else {
                newPanStep = PanGestureStep(
                    wasFacedUpBeforeGesture: self.isFaceUp
                    ,layerTransformBeforeAnimation: previousPanStep.layerTransformBeforeAnimation
                    ,translation: recognizer.translation(in: cardSuperview)
                    ,velocity: recognizer.velocity(in: cardSuperview)
                    ,previousStep: previousPanStep
                )
            }
        } else {
            newPanStep = PanGestureStep(
                wasFacedUpBeforeGesture: previousPanStep.wasFacedUpBeforeGesture
                ,layerTransformBeforeAnimation: previousPanStep.layerTransformBeforeAnimation
                ,translation: recognizer.translation(in: cardSuperview)
                ,velocity: recognizer.velocity(in: cardSuperview)
                ,previousStep: previousPanStep
            )
        }
        
        
        let recognizerEndingStates : [UIGestureRecognizer.State] = [.failed, .cancelled, .ended]
        endingAnimation =  recognizerEndingStates.contains(recognizer.state)

        
        let finalPanStep:PanGestureStep?
        
        // some magic happens here with a secret algorithm in the real game.
        // please implement your own if you want to use it !
        if endingAnimation {
            finalPanStep = newPanStep
        } else {
            finalPanStep = newPanStep
        }
        
        self.previousPanGestureStep = finalPanStep

    }
    
    private let screenBoundsUnit = UIScreen.main.bounds.size.maxPoint.distanceToOrigin
    private let deviceIsIpad = (UIDevice.current.userInterfaceIdiom == .pad)
    private lazy var velocityMasterUnit : CGFloat = deviceIsIpad ? 1000 : 500
}


// MARK: 3d card transformations
extension PlayableCardViewController {
    func panDistanceMasterUnit(forVelocity velocity: CGFloat?) -> CGFloat {
        let velocityFactor : CGFloat = {
            if let velocity {
                let value = (velocity / velocityMasterUnit)
                return value > 1 ? value : 1
            } else {
                return 1
            }
        }()
        return screenBoundsUnit / (4 * velocityFactor)
    }
    func angle(fromFactor:CGFloat) -> CGFloat {
        return fromFactor * CGFloat.pi
    }
    func CATransform3DMakeCardTranslation(towards:CGPoint) -> CATransform3D {
        CATransform3DMakeTranslation(towards.x * 0.75, towards.y * 0.75, 0)
    }
    func CATransform3DMakeCardSwipe(fromFactor:CGFloat, fromVector:CGFloat3d) -> CATransform3D {
        CATransform3DMakeRotation(angle(fromFactor:fromFactor)
                                  , fromVector.x
                                  , fromVector.y
                                  , fromVector.z)
    }
    func CATransform3DCardZoom(_ currentTransform:CATransform3D, significantTranslationDistance:CGFloat) -> CATransform3D {
        let progressiveFactor = significantTranslationDistance / panDistanceMasterUnit(forVelocity: nil)
        let maxZoomFactor = maximumZoomedSizeToRealSize
        let scaleFactor = min(maxZoomFactor, ((maxZoomFactor-1)*progressiveFactor/8)+1)
        return CATransform3DScale(currentTransform, scaleFactor, scaleFactor, scaleFactor)
    }
    func CATransform3DRotateZ(_ currentTransform:CATransform3D, angle:CGFloat) -> CATransform3D {
        CATransform3DRotate(currentTransform, angle , 0, 0, 1)
    }
    func CATransform3DCardAboveOthers(_ currentTransform:CATransform3D) -> CATransform3D {
        CATransform3DConcat(currentTransform, CATransform3DMakeTranslation(0, 0, 1000))
    }
    func CATransform3DCardSoftenAngle(_ currentTransform:CATransform3D) -> CATransform3D {
        let rotationZ = atan2(currentTransform.m12, currentTransform.m11)
        let correctiveRotationZ = rotationZ.roundToNearestStep(step: .pi/2, roundedValueToRealValueFactor: 0.75) - rotationZ
        return CATransform3DConcat(currentTransform, CATransform3DMakeRotation(correctiveRotationZ , 0, 0, 1))
    }
}

// MARK: - UI parameters
extension PlayableCardViewController {
    struct UIParameter {
        static let AnimationMaximumDurationMovingBack : TimeInterval = 1
        static let RoundedAngleFactorAtCreationByDefault:CGFloat = 0.05
        static let AnimationDurationShadowOff = 0.25
    }
}

// MARK: - UI calculated parameters
extension PlayableCardViewController {
    var cardSize : CGFloat {
        delegate?.cardSize ?? view.bounds.width
    }
    func animationDurationMovingBack(_ translationMovement:CGPoint) -> TimeInterval {
        let translationRatio = ratioToScreenSize(translationMovement)
        let durationRatio = pow(4,translationRatio-1)
        return UIParameter.AnimationMaximumDurationMovingBack * durationRatio
    }
}

// MARK: - General utilities
extension PlayableCardViewController {
    private func ratioToScreenSize(_ point:CGPoint) -> CGFloat {
        return point.distanceToOrigin / UIScreen.main.bounds.size.maxPoint.distanceToOrigin
    }
}
