//
//  FictiveCardView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 04/03/2024.
//

import UIKit

class FictiveCardView: UIView {

    
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
        backgroundColor = CardView.UIParameter.backgroundColorNotFacedUpDefaultValue
        
        let constraints = [
            widthAnchor.constraint(equalTo: heightAnchor)
        ]
        constraints.last!.priority = .required
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(constraints)

        let coverImage = UIImageView(image: UIImage(named: CardViewModel.UIParameter.CoverImageDefault))
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.contentMode = .scaleAspectFit
        addSubviewFullsized(coverImage)
//        // Apply rounded corners to contentView
//        contentView.layer.cornerRadius = cornerRadius
//        contentView.layer.masksToBounds = true
        
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = UIParameter.Radius
        layer.masksToBounds = false
        
        // Apply a shadow
        layer.shadowRadius = UIParameter.Shadow.Radius
        layer.shadowOpacity = UIParameter.Shadow.Opacity
        layer.shadowColor = UIParameter.Shadow.Color
//        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Improve scrolling performance with an explicit shadowPath
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: UIParameter.Radius
        ).cgPath
    }
}

extension FictiveCardView {
    struct UIParameter {
        static let Radius = 3.0
        
        struct Shadow {
            static let Radius = 5.0
            static let Opacity : Float = 0.2
            static let Color = UIColor.black.cgColor
        }
    }
}
