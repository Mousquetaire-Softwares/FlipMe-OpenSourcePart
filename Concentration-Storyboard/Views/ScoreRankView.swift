//
//  ScoreRankView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 30/04/2024.
//

import UIKit

class ScoreRankView: UIView {

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    @IBOutlet weak var badRank: UIImageView!
    @IBOutlet weak var goodRank1: UIImageView!
    @IBOutlet weak var goodRank2: UIStackView!
    @IBOutlet weak var goodRank2Image1: UIImageView!
    @IBOutlet weak var goodRank2Image2: UIImageView!
    @IBOutlet weak var goodRank3: UIStackView!
    @IBOutlet weak var goodRank3Line1Image1: UIImageView!
    @IBOutlet weak var goodRank3Line2: UIStackView!
    @IBOutlet weak var goodRank3Line2Image1: UIImageView!
    @IBOutlet weak var goodRank3Line2Image2: UIImageView!
    @IBOutlet weak var perfectRank: UIImageView!
    
    
    func setupImages(badRankImage:UIImage?, goodRankImage:UIImage?, perfectRankImage:UIImage?) {
        badRank.image = badRankImage
        goodRank1.image = goodRankImage
        goodRank2Image1.image = goodRankImage
        goodRank2Image2.image = goodRankImage
        goodRank3Line1Image1.image = goodRankImage
        goodRank3Line2Image1.image = goodRankImage
        goodRank3Line2Image2.image = goodRankImage
        perfectRank.image = perfectRankImage
    }
    
    func reset() {
        goodRank2.isHidden = false
        goodRank3.isHidden = false
        goodRank3Line2.isHidden = false
        
        
        badRank.alpha = 0
        goodRank1.alpha = 0
        goodRank2Image1.alpha = 0
        goodRank2Image2.alpha = 0
        goodRank3Line1Image1.alpha = 0
        goodRank3Line2Image1.alpha = 0
        goodRank3Line2Image2.alpha = 0
        perfectRank.alpha = 0
        
        badRank.isHidden = false
        goodRank1.isHidden = false
        goodRank2Image1.isHidden = false
        goodRank2Image2.isHidden = false
        goodRank3Line1Image1.isHidden = false
        goodRank3Line2Image1.isHidden = false
        goodRank3Line2Image2.isHidden = false
        perfectRank.isHidden = false
        
        badRank.transform = .identity
        goodRank1.transform = .identity
        goodRank2Image1.transform = .identity
        goodRank2Image2.transform = .identity
        goodRank3Line1Image1.transform = .identity
        goodRank3Line2Image1.transform = .identity
        goodRank3Line2Image2.transform = .identity
        perfectRank.transform = .identity
    }
    
    
    func showRank(_ rank:ScoreRank?) {
        reset()
        guard let rank else { return }
        
        switch(rank) {
        case .Zero:
            badRank.alpha = 1
        case .One:
            goodRank1.alpha = 1
        case .Two:
            goodRank2Image1.alpha = 1
            goodRank2Image2.alpha = 1
        case .Three:
            goodRank3Line1Image1.alpha = 1
            goodRank3Line2Image1.alpha = 1
            goodRank3Line2Image2.alpha = 1
        case .Four:
            perfectRank.alpha = 1
        }
    }
    
}
