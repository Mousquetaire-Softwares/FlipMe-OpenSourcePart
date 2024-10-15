//
//  HelpAndCreditsViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 08/04/2024.
//

import UIKit

class HelpAndCreditsViewController: UIViewController {

    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)

        animateParticles(on: particlesPlaceholder1)
        animateParticles(on: particlesPlaceholder2)
    }

    
    @IBOutlet weak var particlesPlaceholder1: UIView!
    @IBOutlet weak var particlesPlaceholder2: UIView!
    
    private func animateParticles(on target:UIView) {
        let vfx = VfxParticlesExplosionViewController(numberOfParticles: UIParameter.ParticlesNumber
                                                      , particlesImages: ParticlesLibraryViewModel.Stars.Yellow.UIImages
                                                      , duration: UIParameter.ParticlesAnimationDuration
                                                      , maximumDelayByParticle: UIParameter.MaximumDelayByParticle
                                                      , delay: UIParameter.ParticlesAnimationDelay)
        if let container = self.view
            , let vfxView = vfx.view
        {
            self.addChild(vfx)
            vfxView.translatesAutoresizingMaskIntoConstraints = false
            let subContainer = UIView()
            subContainer.alpha = 0
            container.addSubview(subContainer)
            subContainer.translatesAutoresizingMaskIntoConstraints = false
            subContainer.setContraints(toLookLike: target)
            subContainer.addSubviewFullsized(vfxView)
            container.layoutIfNeeded()
            vfx.didMove(toParent: self)
            
            vfx.startAnimation()
            UIView.animate(withDuration: UIParameter.MaximumDelayByParticle
                           , delay: UIParameter.ParticlesAnimationDelay
                           , options: [.curveEaseIn]
                           , animations: {
                subContainer.layoutIfNeeded()
                subContainer.alpha = 0.8
            }
            )
        }
        
        
    }

    @IBAction func closeButtonTapAction(_ sender: Any) {
        dismiss(animated: true)
    }

}

extension HelpAndCreditsViewController {
    struct UIParameter {
        static let ParticlesNumber = 10
        static let ParticlesAnimationDuration : TimeInterval = 2
        static let MaximumDelayByParticle : TimeInterval = 0.5
        static let ParticlesAnimationDelay : TimeInterval = 0
    }
}
