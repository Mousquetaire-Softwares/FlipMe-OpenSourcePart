//
//  VfxParticlesExplosionViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 05/02/2024.
//

import Foundation
import UIKit


class VfxParticlesExplosionViewController: VfxViewController {
    
    init(numberOfParticles:Int
         , particlesImages : [UIImage]
         , duration:TimeInterval
         , maximumDelayByParticle: TimeInterval
         , delay:TimeInterval
         , completion: ((Bool)->())? = nil)
    {
        self.numberOfParticles = numberOfParticles
        self.particlesImages = particlesImages
        self.completion = completion
        self.duration = duration
        self.maximumDelayByParticle = min(maximumDelayByParticle, duration)
        self.delay = delay
        super.init(nibName: nil, bundle: nil)
        self.view.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not valid use of \(Self.description())")
    }
    
    private let numberOfParticles : Int
    private let particlesImages : [UIImage]
    private var frameSize : CGSize { self.view.bounds.size }
    private let completion : ((Bool)->())?
    private let duration:TimeInterval
    private let maximumDelayByParticle:TimeInterval
    private let delay: TimeInterval
    
    
    func startAnimation(doNotDismissWhenFinished: Bool = false)
    {
        let maximumDuration = self.duration
        let maxSize = max(frameSize.width,frameSize.height) * UIParameter.MaxLabelSizeToFrameSize
        
        // creating and animating all particles
        for _ in 0..<numberOfParticles {
            guard let particleImage = particlesImages.randomElement() else { break }
            
            let particleView = UIView()
            let particleImageView = UIImageView(image: particleImage)
            particleImageView.translatesAutoresizingMaskIntoConstraints = false
            particleView.addSubviewFullsized(particleImageView)
            
            particleImageView.contentMode = .scaleAspectFit
            
            let sizeSide = CGFloat.random(in: maxSize/2...maxSize)
            let origin = CGPoint(x: CGFloat.random(in: frameSize.width*3/8...frameSize.width*5/8)
                                 ,y: CGFloat.random(in: frameSize.height*3/8...frameSize.height*5/8))
            
            self.view.addSubview(particleView)
            let frameRect = CGRect(x: 0
                                   , y: 0
                                   , width: sizeSide
                                   , height: sizeSide)
            particleView.frame = frameRect.offsetBy(dx: origin.x - frameRect.midX
                                                    , dy: origin.y - frameRect.midY)
            
            let affineTarget = CGPoint(x: Double.random(in: 0...frameSize.width) - frameSize.width/2
                                       , y: Double.random(in: 0...frameSize.height) - frameSize.height/2)
            
            // initial state of particle
            particleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            particleImageView.alpha = 0
            
            // final state
            let finalTransform = CGAffineTransform(translationX: affineTarget.x*UIParameter.MaxAffineTargetToFrameSize
                                                   , y: affineTarget.y*UIParameter.MaxAffineTargetToFrameSize)
            
            // Random delay before real apparition and moving
            let apparitionDelay = Double.random(in: 0...maximumDelayByParticle)
            let movingDuration = maximumDuration - apparitionDelay
            
            // Animation to make the particle appearing progressively.
            // The duration could be zero if there is no delay (to have a very fast and reactive effect on screen) or longer if the particle appears later.
            UIView.animate(withDuration: min(apparitionDelay/2, movingDuration/6)
                           ,delay: delay + apparitionDelay
                           ,options: [.curveEaseOut]
                           ,animations: {
                particleImageView.alpha = 1
            }
            )
            
            // Animation to make the particle move
            UIView.animate(withDuration: movingDuration
                           ,delay: delay + apparitionDelay
                           ,options: [.curveEaseOut]
                           ,animations: {
                particleView.transform = finalTransform
            }
            )
        }
        
        // Making every particle disappear at the end of the animation
        UIView.animate(withDuration: maximumDuration*1/6
                       ,delay: delay + maximumDuration*5/6
                       ,options: [.curveEaseIn]
                       ,animations: {
            self.view.alpha = 0
        }
                       , completion: {
            _ in
            if !doNotDismissWhenFinished {
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
            if let completion = self.completion {
                completion(true)
            }
        }
        )
        
    }
    
}

extension VfxParticlesExplosionViewController {
    struct UIParameter {
        static let MaxLabelSizeToFrameSize : CGFloat = 1.0/4
        static let MaxAffineTargetToFrameSize : CGFloat = 1.2
        static var DurationOfZoomPartRatio : CGFloat { CGFloat(1) / MaxAffineTargetToFrameSize }
    }
}
