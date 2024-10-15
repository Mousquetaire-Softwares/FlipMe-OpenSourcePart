//
//  HelperForSwipingViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 23/10/2023.
//

import UIKit

protocol HelperForSwipingViewControllerDelegate : AnyObject {
    func randomImageNameInGametable() -> String?
}

class HelperForSwipingViewController: UIViewController {
    init?(delegate:HelperForSwipingViewControllerDelegate, coder:NSCoder) {
        self.delegate = delegate
        super.init(coder: coder)
    }
    
    @available(*,unavailable,renamed: "init(delegate:coder:)")
    required init?(coder: NSCoder) {
        fatalError("This class doesnt support this initializer")
    }
    
    private let delegate:HelperForSwipingViewControllerDelegate
    
    // MARK: - General UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.alpha = UIParameter.ViewAlpha
        [view.layer].forEach{
            $0.shadowColor = UIParameter.Shadow.Color
            $0.shadowRadius = UIParameter.Shadow.Radius
            $0.shadowOpacity = UIParameter.Shadow.Opacity
            $0.shadowOffset = UIParameter.Shadow.Offset
        }
        
        cardViewController = PresentationCardViewController(imageName: delegate.randomImageNameInGametable())
        
        addChild(cardViewController)
        cardViewContainerView.addSubviewFullsized(cardViewController.view)
        cardViewController.didMove(toParent: self)
        
        cardViewController.isVisible = true
        
        [handImage.layer].forEach{
            $0.shadowColor = UIColor.black.cgColor
            $0.shadowRadius = 5
            $0.shadowOpacity = 0.5
            $0.shadowOffset = CGSize(width: 2, height: 2)
        }
        
        view.layer.cornerRadius = UIParameter.CornerRadius
        
        // animation of beginning appearance - first value of view.transform is smaller and translated to make a bounce effect coming from the right side
        view.transform = view.transform.translatedBy(x: view.bounds.width / 4, y: 0)
        view.transform = view.transform.scaledBy(x: 0.7, y: 0.7)
        
        UIView.animate(withDuration: UIParameter.AppearanceAnimationDuration
                       ,delay: 0
                       ,usingSpringWithDamping: 0.7
                       ,initialSpringVelocity: 0
                       ,options: []
                       ,animations: {
            self.view.transform = .identity
        }
        )
    }
    
    override func viewDidLayoutSubviews() {
        swipingDirection = CGPoint(x: (view.bounds.width - viewHand.bounds.width) * 7 / 20
                                   , y: -(view.bounds.height - viewHand.bounds.height) * 7 / 20)
        
        animate()
    }
    
    // MARK: - Swiping direction
    var swipingDirection:CGPoint = .zero
    private var swipingDirectionNextChangeOnBothAxis = true
    private func changeSwipingDirection() {
        swipingDirection.y *= -1
        if swipingDirectionNextChangeOnBothAxis {
            swipingDirection.x *= -1
        }
        swipingDirectionNextChangeOnBothAxis = !swipingDirectionNextChangeOnBothAxis
    }
    
    
    // MARK: - CardView
    private(set) var cardViewController : PresentationCardViewController!
    
    @IBOutlet weak var cardViewContainerView: UIView!
    
    // MARK: - Hand views
    @IBOutlet weak var viewHand: UIView!
    @IBOutlet weak var handImage: UIImageView!
    private var viewHandTransformDefault = CATransform3DIdentity
    
    // MARK: - Animation engine
    func animate(step:Int = 0) {
        let steps = 6
        let duration: TimeInterval
        let delay: TimeInterval
        let options: UIView.AnimationOptions
        let animations : () -> Void
        
        switch step % steps {
            // step 0 : initialization
            // viewHand is transformed to appear away from its real position (translation)
        case 0:
            duration = 0
            delay = 0
            options = []
            animations = { [weak self]  in
                self?.changeSwipingDirection()
                
                self?.cardViewController.cardView.layer.transform = CATransform3DIdentity
                self?.cardViewController.cardView.movingContentView.layer.transform = CATransform3DIdentity
                self?.cardViewController.cardView.movingContentView.contentView.layer.transform = CATransform3DIdentity
                self?.cardViewController.cardView.movingContentView.contentView.isFaceUp = false
                self?.cardViewController.setShadow(.WhenNotAnimated)
                self?.handImage.layer.transform = CATransform3DIdentity
                self?.viewHand.layer.transform = CATransform3DTranslate(self!.viewHandTransformDefault, -self!.swipingDirection.x, self!.swipingDirection.y, 0)
                self?.viewHand.alpha = 1
            }
            // step 1 : viewHand moves back to its position
        case 1:
            duration = UIParameter.TotalAnimationDuration / 4 * 3/4
            delay = 0
            options = [.curveEaseInOut]
            animations = { [weak self]  in
                self?.viewHand.layer.transform = CATransform3DIdentity
            }
            // step 2 : viewHand rotates & scales down to simulate touch on screen
        case 2:
            duration = UIParameter.TotalAnimationDuration / 4 * 2/4
            delay = UIParameter.TotalAnimationDuration / 4 * 1/4
            options = []
            animations = { [weak self] in
                var transform = CATransform3DMakeRotation(.pi/15, 0, 0, 1)
                transform = CATransform3DScale(transform, UIParameter.HandViewTouchSizeToOriginalSize, UIParameter.HandViewTouchSizeToOriginalSize, 1)
                self?.handImage.layer.transform = CATransform3DConcat(self!.viewHandTransformDefault, transform)
                self?.cardViewController.setShadow(.WhenAnimated)
            }
            // step 3 : viewHand and CardView moves while card is flipping (first part - card is face down)
        case 3:
            duration = UIParameter.TotalAnimationDuration / 4 * 3/4
            delay = UIParameter.TotalAnimationDuration / 4 * 1/4
            options = [.curveLinear]
            animations = { [weak self] in
                if let self = self {
                    let translationTowards = self.swipingDirection.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
                    
                    [self.cardViewController.cardView as UIView, self.viewHand]
                        .forEach{ view in
                            view.layer.transform = CATransform3DMakeTranslation(translationTowards.x, translationTowards.y, 0)
                        }
                    let swipeVectorX = -translationTowards.y / max(translationTowards.x.abs,translationTowards.y.abs)
                    let swipeVectorY = translationTowards.x / max(translationTowards.x.abs,translationTowards.y.abs)
                    let cardViewLayer = self.cardViewController.cardView.movingContentView.contentView.layer
                    cardViewLayer.transform = CATransform3DRotate(cardViewLayer.transform, .pi/2, swipeVectorX, swipeVectorY, 0)
                }
            }
            // step 4 : viewHand and CardView moves while card is flipping (second part - card is face up)
        case 4:
            duration = UIParameter.TotalAnimationDuration / 4 * 3/4
            delay = 0
            options = [.curveLinear]
            animations = { [weak self] in
                if let self {
                    //                    self.cardViewController.cardView.setFaceUp(true, action: .DoNotAnimate)
                    self.cardViewController.cardView.movingContentView.contentView.isFaceUp = true
                    let translationTowards = self.swipingDirection
                    
                    [self.cardViewController.cardView as UIView, self.viewHand]
                        .forEach{ view in
                            view.layer.transform = CATransform3DMakeTranslation(translationTowards.x, translationTowards.y, 0)
                        }
                    let swipeVectorX = -translationTowards.y / max(translationTowards.x.abs,translationTowards.y.abs)
                    let swipeVectorY = translationTowards.x / max(translationTowards.x.abs,translationTowards.y.abs)
                    let cardViewLayer = self.cardViewController.cardView.movingContentView.contentView.layer
                    cardViewLayer.transform = CATransform3DRotate(cardViewLayer.transform, .pi/2, swipeVectorX, swipeVectorY, 0)
                }
            }
            // step 5 : animation stops and waits
        case 5:
            duration = UIParameter.TotalAnimationDuration / 4 * 3/4
            delay = 0
            options = [.curveLinear]
            animations = { [weak self] in
                self?.viewHand.alpha = 0.99
            }
        default:
            return
        }
        UIView.animate(withDuration: duration
                       , delay: delay
                       , options: options
                       , animations: animations
                       , completion: { [weak self] (finished) in self?.animate(step: (step+1)%steps) })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension HelperForSwipingViewController {
    struct UIParameter {
        //        static let HandViewSizeToCardSize : CGFloat = 2
        static let HandViewTouchSizeToOriginalSize : CGFloat = 0.6
        static let TotalAnimationDuration : TimeInterval = 2
        static let AppearanceAnimationDuration : TimeInterval = 0.5
        
        static let ViewAlpha : CGFloat = 0.9
        static let CornerRadius : CGFloat = 20
        
        struct Shadow {
            static let Radius : CGFloat = 5
            static let Opacity : Float = 1
            static let Color : CGColor = UIColor.black.cgColor
            static let Offset = CGSize(width: 2, height: 2)
        }
    }
}
