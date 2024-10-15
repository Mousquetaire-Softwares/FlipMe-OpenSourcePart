//
//  RoundedShadowedView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 04/03/2024.
//

import UIKit

@IBDesignable
class RoundedShadowedView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    
    var cornerRadius : CGFloat = UIParameter.CornerRadiusDefault {
        didSet { setupView() }
    }
    
    var shadowColor : CGColor = UIParameter.ShadowDefault.Color {
        didSet { setupView() }
    }
    var shadowOpacity : Float  = UIParameter.ShadowDefault.Opacity {
        didSet { setupView() }
    }
    var shadowRadius : CGFloat  = UIParameter.ShadowDefault.Radius {
        didSet { setupView() }
    }
    
    //common func to init our view
    private func setupView() {
        clipsToBounds = true
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Improve scrolling performance with an explicit shadowPath
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }

}

extension RoundedShadowedView {
    struct UIParameter {
        static let CornerRadiusDefault : CGFloat = 10
        
        struct ShadowDefault {
            static let Radius : CGFloat = 10
            static let Opacity : Float = 0.3
            static let Color : CGColor = UIColor.black.cgColor
        }
    }
}
