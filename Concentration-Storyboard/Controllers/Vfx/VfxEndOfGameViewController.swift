//
//  EndOfGameViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 11/01/2024.
//

import UIKit

class VfxEndOfGameViewController : UIViewController {

    init(matchedCards:[[CardViewController]]) {
        self.matchedCardViewControllers = matchedCards
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private let matchedCardViewControllers : [[CardViewController]]
    private var frameSize : CGSize { self.view.bounds.size }
    

    func startSuccessAnimations() -> TimeInterval {
        let duration1 = starsAnimation(numberOfParticles: 100, duration: UIParameter.TotalAnimationDuration)
        let duration2 = bouncingMatchedCardsAnimation(duration: UIParameter.TotalAnimationDuration / 3)
        
        return max(duration1,duration2)
    }
    
    func bouncingMatchedCardsAnimation(duration: TimeInterval) -> TimeInterval {
        var higherDelay : TimeInterval = 0
        
        for (offset,vcs) in matchedCardViewControllers.enumerated() {
            let delay : TimeInterval = Double(offset) / 10
            higherDelay = max(delay,higherDelay)
            
            let views = vcs.compactMap({ $0.view })

            UIView.animate(withDuration: duration / 2
                           ,delay: delay
                           ,options: [.curveEaseOut]
                           ,animations: {
                views.forEach{
                    $0.transform = $0.transform.scaledBy(x: 2, y: 2)
                }
            }
                           ,completion: {
                _ in
                UIView.animate(withDuration: duration / 2
                               ,delay: 0
                               ,options: [.curveEaseIn]
                               ,animations: {
                    views.forEach{
                        $0.transform = $0.transform.scaledBy(x: 0.5, y: 0.5)
                    }
                }
                )
            }
            )
        }
        return duration + higherDelay
    }
    
    
    
//
//    func rotatingMatchedCardsAnimation() {
//        
//        for (offset,(cardVC1,cardVC2)) in matchedCardViewControllers.enumerated() {
//            let delay : TimeInterval = Double(offset) / 10
//            
//            if let view1 = cardVC1.view, let view2 = cardVC2.view {
//                let finalTransformView1 = view1.transform
//                let finalTransformView2 = view2.transform
//                UIView.animate(withDuration: 1/3
//                               ,delay: delay
//                               ,options: [.curveEaseIn]
//                               ,animations: {
//                    view1.transform = .identity.rotated(by: .pi*2/3)
//                    view2.transform = .identity.rotated(by: .pi*2/3)
//                }
//                               ,completion: {
//                    _ in
//                    UIView.animate(withDuration: 1/3
//                                   ,delay: 0
//                                   ,options: [.curveLinear]
//                                   ,animations: {
//                        view1.transform = .identity.rotated(by: .pi*4/3)
//                        view2.transform = .identity.rotated(by: .pi*4/3)
//                    }
//                                   ,completion: {
//                        _ in
//                        UIView.animate(withDuration: 1/3
//                                       ,delay: 0
//                                       ,options: [.curveEaseOut]
//                                       ,animations: {
//                            view1.transform = finalTransformView1
//                            view2.transform = finalTransformView2
//                            //                        view2.transform = CGAffineTransformConcat(.identity.rotated(by: .pi),view2.transform)
//                        }
//                        )
//                    }
//                    )
//                }
//                )
//            }
//        }
//    }
    
    
    private func starsAnimation(numberOfParticles:Int, duration:TimeInterval) -> TimeInterval {
        
        let heightMargin = CGFloat(20)
        var delay : TimeInterval = 0
        let groupsOfStars = Int.random(in: 4...9)
        let groupOfStarsDuration = duration * 3 / 4
        let delayBetweenGroupsOfStars : TimeInterval = (duration - groupOfStarsDuration) / Double(groupsOfStars - 1)
        
        for y in stride(from: heightMargin
                        , to: frameSize.height - heightMargin
                        , by: frameSize.height / CGFloat(groupsOfStars))
        {
            launchStars(origin: CGPoint(x: 0, y: Int(y))
                        , direction: CGPoint(x: 1, y: 0)
                        , numberOfParticles: numberOfParticles/5
                        , maximumDuration: groupOfStarsDuration
                        , delay:delay)
            launchStars(origin: CGPoint(x: Int(frameSize.width), y: Int(y))
                        , direction: CGPoint(x: -1, y: 0)
                        , numberOfParticles: numberOfParticles/5
                        , maximumDuration: groupOfStarsDuration
                        , delay:delay)
            delay += delayBetweenGroupsOfStars
        }
        
        return delay + groupOfStarsDuration
    }
    
    
    private func launchStars(origin:CGPoint
                             , direction:CGPoint
                             , numberOfParticles:Int
                             , maximumDuration:TimeInterval
                             , delay:TimeInterval)
    {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviewFullsized(container)
        view.layoutIfNeeded()
        
        let maxStarSizeSide = max(frameSize.width,frameSize.height) * UIParameter.MaxParticleSizeToFrameSize
        let affineTargetSize = CGSize(width: direction.x * frameSize.width/2, height: 100)
        
        var viewsAndTransformations = [(view:UIImageView
                                        , halfTransform:CGAffineTransform
                                        , finalTransform:CGAffineTransform)]()
        
        for _ in 0..<numberOfParticles {
            guard let particleImage = UIParameter.ParticlesImages.randomElement() else { break }
            
            let particleView = UIImageView(image: particleImage)
            particleView.contentMode = .scaleAspectFit
            
            let starSize = CGFloat.random(in: maxStarSizeSide/2...maxStarSizeSide)

            container.addSubview(particleView)
            let frameRect = CGRect(x: 0
                                   , y: 0
                                   , width: starSize
                                   , height: starSize)
            particleView.frame = frameRect.offsetBy(dx: origin.x - frameRect.midX
                                                    , dy: origin.y - frameRect.midY)
            
            let affineTarget = CGPoint(x: Int(affineTargetSize.width).arc4random
                                       ,y: Int(affineTargetSize.height).arc4random)


            particleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            let halfTransform = CGAffineTransform(translationX: affineTarget.x
                                                  ,y: affineTarget.y)
            let finalTransform = CGAffineTransform(translationX: affineTarget.x*UIParameter.MaxAffineTargetToFrameSize
                                                   , y: affineTarget.y*UIParameter.MaxAffineTargetToFrameSize)
            
            viewsAndTransformations.append((particleView, halfTransform, finalTransform))
        }
        
        // Animate all particles
        UIView.animate(withDuration: maximumDuration
                       ,delay: delay
                       ,options: [.curveEaseOut]
                       ,animations: {
            viewsAndTransformations.forEach{
                $0.view.transform = $0.finalTransform
            }
        }
        )
        
        // Making every particle disappear at the end of the animation
        UIView.animate(withDuration: maximumDuration*1/3
                       ,delay: delay + maximumDuration*2/3
                       ,options: [.curveEaseIn]
                       ,animations: {
            container.alpha = 0
        }
                       , completion: {
            _ in
            container.removeFromSuperview()
        }
        )
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

extension VfxEndOfGameViewController {
    struct UIDesign {
    }
    struct UIParameter {
        static let MaxParticleSizeToFrameSize : CGFloat = 1.0/20
        static let MaxAffineTargetToFrameSize : CGFloat = 1.2
        static var DurationOfZoomPartRatio : CGFloat { CGFloat(1) / MaxAffineTargetToFrameSize }
        
        static let TotalAnimationDuration : TimeInterval = 3
        
        static let ParticlesImages = {
            Array(ParticlesLibraryViewModel.Stars.Yellow.UIImages)
            + Array(ParticlesLibraryViewModel.Stars.Yellow.UIImages)
            + Array(ParticlesLibraryViewModel.Stars.Yellow.UIImages)
            + Array(ParticlesLibraryViewModel.Stars.Green.UIImages)
            + Array(ParticlesLibraryViewModel.Stars.Pink.UIImages)
        }()
    }
}
