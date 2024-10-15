//
//  CardView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 07/07/2023.
//

import UIKit



@IBDesignable
class CardView: UIView {
    
    class MovingContentView : UIView {
        lazy var contentView:ContentView = {
            let view = ContentView()
            view.translatesAutoresizingMaskIntoConstraints = false
//            view.contentMode = .redraw
            view.backgroundColor = backgroundColor
            insertSubview(view, at: 0)
            NSLayoutConstraint.activate([
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                view.widthAnchor.constraint(equalTo: self.widthAnchor),
                view.heightAnchor.constraint(equalTo: self.heightAnchor)]
            )
            return view
        }()
        
        private(set) var contentViewLayerIsUpsideDown = false
        func contentViewHasBeenSwiped() {
            contentViewLayerIsUpsideDown = !contentViewLayerIsUpsideDown
        }
        
        
        /// Manages the final appearance of card : backcolor, rounded edges and the two images : cover and cardimage
        /// isFaceUp property will show one image or the other
        /// this view is supposed to be transformed with CATransform3d, so cardimage is "swiped" in 3d to match the right direction with cover image
        class ContentView : UIView {
            override init(frame: CGRect) {
              super.init(frame: frame)
              setupView()
            }
            
            required init?(coder aDecoder: NSCoder) {
              super.init(coder: aDecoder)
              setupView()
            }
            
            //common func to init our view
            private func setupView() {
                // Set masks to bounds to false to avoid the shadow
                // from being clipped to the corner radius
    //            layer.masksToBounds = false
                
                // Apply a shadow
                layer.shadowRadius = CardView.UIParameter.NotAnimatedShadow.Radius
                layer.shadowOpacity = CardView.UIParameter.NotAnimatedShadow.Opacity
                layer.shadowColor = CardView.UIParameter.NotAnimatedShadow.Color
                
                isFaceUp = false
            }
            
            // MARK: - Mystery label
            private lazy var mysteryLabel : UILabel = {
                let label = createCardLabel()
                insertSubview(label, aboveSubview: coverImage)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.setContraints(toLookLike: coverImage)
                label.isHidden = !showMysteryLabel
                return label
            }()
            
            func createCardLabel() -> UILabel {
                let label = UILabel()
                label.attributedText  = {
                    var attFont = UIFont.preferredFont(forTextStyle: .title1).withSize(100)
                    attFont = UIFontMetrics(forTextStyle: .title1).scaledFont(for: attFont)
                    
                    let attParagraph = NSMutableParagraphStyle()
                    attParagraph.alignment = .center

                    let attShadow = NSShadow()
                    attShadow.shadowColor = UIColor.yellow.withAlphaComponent(1)
                    attShadow.shadowBlurRadius = 5
                    
                    let labelAttributes: [NSAttributedString.Key:Any] =
                    [   .paragraphStyle: attParagraph
                        , .font: attFont
                        , .foregroundColor: UIColor.white
                        , .shadow: attShadow
                    ]
                    return NSAttributedString(string: "?", attributes: labelAttributes)
                }()
                label.adjustsFontSizeToFitWidth = true
                return label
            }


            // MARK: - Images of card
            fileprivate var cardImageBackgroundColor : UIColor?
            fileprivate var coverImageBackgroundColor : UIColor?
            
            
            fileprivate lazy var coverImage: UIImageView! = {
                let image = UIImageView(frame: .zero)
                insertSubview(image, at: 0)
                configure(image, scaleBy: UIParameter.ImageToViewSize)
                return image
            }()
            
            private lazy var cardImagesContainer: UIView! = {
                let view = UIView(frame: .zero)
                insertSubview(view, at: 1)
                configure(view, scaleBy: UIParameter.ImageToViewSize)
                return view
            }()
            
            fileprivate lazy var cardSingleImage: UIImageView! = {
                let image = UIImageView(frame: .zero)
                image.isHidden = true
                cardImagesContainer.insertSubview(image, at: 1)
                configure(image)
                image.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
                return image
            }()
            
            fileprivate lazy var cardTopLeftImage: UIImageView! = {
                let image = UIImageView(frame: .zero)
                image.isHidden = true
                cardImagesContainer.insertSubview(image, at: 1)
                configure(image, scaleBy: 0.6, xAnchor: .left, yAnchor: .top)
                image.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
                return image
            }()
            
            fileprivate lazy var cardBottomRightImage: UIImageView! = {
                let image = UIImageView(frame: .zero)
                image.isHidden = true
                cardImagesContainer.insertSubview(image, at: 1)
                configure(image, scaleBy: 0.6, xAnchor: .right, yAnchor: .bottom)
                image.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
                return image
            }()

            
            
            private func configure(_ view:UIView
                                   , scaleBy:CGFloat = 1
                                   , xAnchor:NSLayoutConstraint.Attribute = .centerX
                                   , yAnchor:NSLayoutConstraint.Attribute = .centerY)
            {
                view.contentMode = .scaleAspectFit
                view.translatesAutoresizingMaskIntoConstraints = false

                if let superview = view.superview {
                    NSLayoutConstraint.activate([
                        NSLayoutConstraint(item: view
                                           , attribute: xAnchor
                                           , relatedBy: .equal
                                           , toItem: superview
                                           , attribute: xAnchor
                                           , multiplier: 1
                                           , constant: 0)
                        ,NSLayoutConstraint(item: view
                                            , attribute: yAnchor
                                            , relatedBy: .equal
                                            , toItem: superview
                                            , attribute: yAnchor
                                            , multiplier: 1
                                            , constant: 0)
                        ,view.widthAnchor.constraint(equalTo: superview.widthAnchor
                                                     , multiplier: scaleBy)
                        ,view.heightAnchor.constraint(equalTo: superview.heightAnchor
                                                      , multiplier: scaleBy)
                    ])
                }
            }
            
            
            // MARK: - View properties and updates
            var showMysteryLabel = false {
                didSet {
                    updateViewFromProperties()
                }
            }

            var isFaceUp:Bool = false {
                didSet {
                    updateViewFromProperties()
                }
            }

            enum CardImageMode { case Empty, Single, Double }
            fileprivate var cardImageMode : CardImageMode = .Empty
            
            private var cardImagesAreHidden : Bool = true {
                didSet {
                    switch cardImageMode {
                    case .Empty:
                        self.cardSingleImage.isHidden = true
                        self.cardTopLeftImage.isHidden = true
                        self.cardBottomRightImage.isHidden = true
                    case .Single:
                        self.cardSingleImage.isHidden = cardImagesAreHidden
                        self.cardTopLeftImage.isHidden = true
                        self.cardBottomRightImage.isHidden = true
                    case .Double:
                        self.cardSingleImage.isHidden = true
                        self.cardTopLeftImage.isHidden = cardImagesAreHidden
                        self.cardBottomRightImage.isHidden = cardImagesAreHidden
                    }
                }
            }
            
            private func updateViewFromProperties() {
                if isFaceUp {
                    cardImagesAreHidden = false
                    coverImage.isHidden = true
                    mysteryLabel.isHidden = true
                } else {
                    cardImagesAreHidden = true
                    coverImage.isHidden = false
                    coverImage.alpha = showMysteryLabel ? UIParameter.CoverImageAlphaIfMysteryLabelIsShown : 1
                    mysteryLabel.isHidden = !showMysteryLabel
                }
                setNeedsDisplay()
            }
            
            // MARK: - Layout and drawing work
            override func layoutSubviews() {
                super.layoutSubviews()
                
                // Improve scrolling performance with an explicit shadowPath
                layer.shadowPath = clippedPath.cgPath
            }
            
            public var clippedPath : UIBezierPath {
                return UIBezierPath(roundedRect: bounds.zoom(by: UIParameter.ContentSizeToViewSize)
                                    , cornerRadius: bounds.width * UIParameter.RoundedCornerRadiusToViewSize)
            }
            
            // Only override draw() if you perform custom drawing.
            // An empty implementation adversely affects performance during animation.
            public override func draw(_ rect: CGRect) {
                // Drawing code
                if cardImagesAreHidden == false || coverImage.isHidden == false {
                    let roundedRect = clippedPath
                    let backColor:UIColor
                    
                    
                    if cardImagesAreHidden == false {
                        backColor = cardImageBackgroundColor ?? UIParameter.backgroundColorFacedUpDefaultValue
                    } else {
                        backColor = coverImageBackgroundColor ?? UIParameter.backgroundColorNotFacedUpDefaultValue
                    }
                    
                    backColor.setFill()
                    roundedRect.fill()
                    roundedRect.addClip()
                }
            }
        }
    }

    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .redraw
        
        NSLayoutConstraint.activate(movingContentViewSizeConstraints)
    }
        
    
//    lazy var movingContentViewSizeConstraints:[NSLayoutConstraint] = [
//        NSLayoutConstraint(item: movingContentView, attribute: .width, relatedBy: .equal
//                           , toItem: self, attribute: .width, multiplier: 1, constant: 0)
//        ,NSLayoutConstraint(item: movingContentView, attribute: .height, relatedBy: .equal
//                            , toItem: self, attribute: .height, multiplier: 1, constant: 0)
//    ]
    private var movingContentViewSizeConstraints:[NSLayoutConstraint] = [] {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
            NSLayoutConstraint.activate(movingContentViewSizeConstraints)
        }
    }
    
    lazy var movingContentView:MovingContentView = {
        let view = MovingContentView()
        view.contentMode = .redraw
        view.backgroundColor = backgroundColor
        
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, at: 0)
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        movingContentViewSizeConstraints = [
            view.widthAnchor.constraint(equalTo: self.widthAnchor),
            view.heightAnchor.constraint(equalTo: self.heightAnchor)]
        
        return view
    }()

    func setMovingContentScale(_ scaleBy:CGFloat) {
        movingContentViewSizeConstraints = [
            NSLayoutConstraint(item: movingContentView, attribute: .width, relatedBy: .equal
                               , toItem: self, attribute: .width, multiplier: scaleBy, constant: 0)
            ,NSLayoutConstraint(item: movingContentView, attribute: .height, relatedBy: .equal
                                , toItem: self, attribute: .height, multiplier: scaleBy, constant: 0)
        ]
    }
    
    @IBInspectable
    private(set) var isFaceUp:Bool = false
    
    private lazy var contentViewLayerTransform = movingContentView.contentView.layer.transform
    enum Action {
        case AnimateAndSwipeContentView(randomOrientation:Bool)
        case DoNotAnimateAndSwipeContentView(randomOrientation:Bool)
        case DoNotAnimate
    }
    func setFaceUp(_ value:Bool
                   , action:Action
                   , completion: ((Bool) -> ())? = nil)
    {
        guard value != isFaceUp else { return }
        
        let randomOrientation : Bool
        switch(action) {
        case .AnimateAndSwipeContentView(let value):
            randomOrientation = value
        case .DoNotAnimateAndSwipeContentView(let value):
            randomOrientation = value
        case .DoNotAnimate:
            randomOrientation = false
        }
        
        let orientation:(x:CGFloat,y:CGFloat)
        if randomOrientation {
            orientation = [(1,0),(0,1),(1,1)].randomElement()!
        } else {
            orientation = (0,1)
        }

        // if a previous setFaceUp operation is still in process, we apply immediately the finished state
        if !CATransform3DEqualToTransform(self.movingContentView.contentView.layer.transform, contentViewLayerTransform) {
            self.movingContentView.contentView.layer.transform = contentViewLayerTransform
            self.movingContentView.contentViewHasBeenSwiped()
            if self.movingContentView.contentView.isFaceUp != self.isFaceUp {
                self.movingContentView.contentView.isFaceUp = self.isFaceUp
            }
        }
        
        let cardViewSwipingHalfTransform = CATransform3DConcat(contentViewLayerTransform, CATransform3DMakeRotation(CGFloat.pi/2 , orientation.x , orientation.y , 0))
        let cardViewSwipingTransform = CATransform3DConcat(contentViewLayerTransform, CATransform3DMakeRotation(CGFloat.pi , orientation.x , orientation.y , 0))
        
        switch(action) {
        case .AnimateAndSwipeContentView:

            contentViewLayerTransform = cardViewSwipingTransform
            
            UIView.animate(withDuration: UIParameter.SetFaceUpAnimationDuration / 2
                           , animations: {
                self.movingContentView.contentView.layer.transform = cardViewSwipingHalfTransform
            }
                           , completion: { finished in
                UIView.animate(withDuration: UIParameter.SetFaceUpAnimationDuration / 2
                               , animations: {
                    if finished {
                        if !CATransform3DEqualToTransform(self.movingContentView.contentView.layer.transform, self.contentViewLayerTransform) {
                            self.movingContentView.contentView.layer.transform = self.contentViewLayerTransform
                            self.movingContentView.contentViewHasBeenSwiped()
                            self.movingContentView.contentView.isFaceUp = value
                        }
                    }
                }
                               , completion: completion
                )
            }
            )
        case .DoNotAnimateAndSwipeContentView:
            contentViewLayerTransform = cardViewSwipingTransform
            movingContentView.contentView.layer.transform = self.contentViewLayerTransform
            movingContentView.contentViewHasBeenSwiped()
            
            self.movingContentView.contentView.isFaceUp = value
            
        case .DoNotAnimate:
            self.movingContentView.contentView.isFaceUp = value
        }
        
        isFaceUp = value
    }
    
    func rotate(clockwise:Bool)
    {
        var rotatingDirection : CGFloat = (clockwise ? -1 : 1)
        if movingContentView.contentViewLayerIsUpsideDown {
            rotatingDirection *= -1
        }
        let rotationZAxis : CGFloat = isFaceUp ? 1 : -1
        movingContentView.layer.transform = CATransform3DRotate(movingContentView.layer.transform
                                                                , .pi/2 * rotatingDirection
                                                                , 0, 0, rotationZAxis)
    }

    func setCoverImage(imageName:String) {
        movingContentView.contentView.coverImage.image = UIImage(named: imageName)
    }
    
    func setSingleCardImage(imageName:String) {
        movingContentView.contentView.cardImageMode = .Single
        movingContentView.contentView.cardSingleImage.image = UIImage(named: imageName)
        movingContentView.contentView.cardTopLeftImage.image = nil
        movingContentView.contentView.cardBottomRightImage.image = nil
    }
    func setDoubleCardImage(imageName1:String,imageName2:String) {
        movingContentView.contentView.cardImageMode = .Double
        movingContentView.contentView.cardSingleImage.image = nil
        movingContentView.contentView.cardTopLeftImage.image = UIImage(named: imageName1)
        movingContentView.contentView.cardBottomRightImage.image = UIImage(named: imageName2)
    }
    func setNoCardImage() {
        movingContentView.contentView.cardImageMode = .Empty
        movingContentView.contentView.cardSingleImage.image = nil
        movingContentView.contentView.cardTopLeftImage.image = nil
        movingContentView.contentView.cardBottomRightImage.image = nil
    }
    
    func setCardImageBackground(_ color:CGColor?) {
        movingContentView.contentView.cardImageBackgroundColor = (color == nil ? nil : UIColor(cgColor: color!))
    }
    
    enum Shadow {
        case None, WhenAnimated, WhenNotAnimated
    }
    func setContentShadow(_ shadow:Shadow) {
        let shadowParameteres : UIParameter.Shadow?
        switch(shadow) {
        case .None:
            shadowParameteres = nil
        case .WhenAnimated:
            shadowParameteres = UIParameter.AnimatedShadow
        case .WhenNotAnimated:
            shadowParameteres = UIParameter.NotAnimatedShadow
        }

        if let shadowParameteres {
            movingContentView.contentView.layer.shadowPath = movingContentView.contentView.clippedPath.cgPath
            movingContentView.contentView.layer.shadowColor = shadowParameteres.Color
            movingContentView.contentView.layer.shadowOpacity = shadowParameteres.Opacity
            movingContentView.contentView.layer.shadowRadius = shadowParameteres.Radius
        } else {
            movingContentView.contentView.layer.shadowPath = nil
            movingContentView.contentView.layer.shadowColor = nil
            movingContentView.contentView.layer.shadowOpacity = 0
            movingContentView.contentView.layer.shadowRadius = 0
        }
    }


    
    
}

extension CardView {
    // allowing to touch and pan the card while it s still moving (animated)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Standard behaviour of hitTest in UIKit
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard alpha >= 0.01 else { return nil }
        
        let pf = layer.presentation()?.frame
        let p = self.convert(point, to: superview)

        if let pf = pf, pf.contains(p) { return self }
        return nil
    }
}


extension CardView {
    // MARK: UI parameters
    struct UIParameter {
        static let CardLabelFontSize : CGFloat = 20.00
        static let ContentSizeToViewSize : CGFloat = 0.85
        static let ImageToViewSize : CGFloat = 0.8
        static let RoundedCornerRadiusToViewSize : CGFloat = 0.08
        static let MaximumZoomedCardSizeToScreenSize : CGFloat = { UIDevice.current.userInterfaceIdiom == .pad ? 0.35 : 0.5 }()

        static let backgroundColorNotFacedUpDefaultValue = #colorLiteral(red: 0.4230141489, green: 0.5621921234, blue: 1, alpha: 1)
        static let backgroundColorFacedUpDefaultValue = #colorLiteral(red: 1, green: 0.903345339, blue: 0.5298934725, alpha: 1)
        
        static let SetFaceUpAnimationDuration : TimeInterval = 0.5
        
        static let CoverImageAlphaIfMysteryLabelIsShown : CGFloat = 0.5

        static let NotAnimatedShadow = Shadow(
            Radius: 5
            ,Opacity: 0.4
            ,Color: UIColor.black.cgColor
        )
        
        static let AnimatedShadow = Shadow(
            Radius: 10
            ,Opacity: 0.8
            ,Color: UIColor.black.cgColor
        )
        struct Shadow {
            let Radius : CGFloat
            let Opacity : Float
            let Color : CGColor
        }
    }
    
}

