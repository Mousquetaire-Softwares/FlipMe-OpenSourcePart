//
//  LauncherViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 03/04/2024.
//

import UIKit

class LauncherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animateParticles(on: particlesZone)
    }
    
    @IBOutlet weak var particlesZone: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    
    override var prefersStatusBarHidden: Bool { true }
    
    private func animateParticles(on target:UIView) {
        let vfx = VfxParticlesExplosionViewController(numberOfParticles: UIParameter.ParticlesNumber
                                                      , particlesImages: ParticlesLibraryViewModel.Stars.UIImages
                                                      , duration: UIParameter.ParticlesAnimationDuration
                                                      , maximumDelayByParticle: UIParameter.MaximumDelayByParticle
                                                      , delay: UIParameter.ParticlesAnimationDelay
                                                      , completion: { _ in self.launchNextController() })
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
                subContainer.alpha = 0.8
            }
            )
        }
        
        
    }
    
    private func launchNextController() {
        performSegue(withIdentifier: UIDesign.SegueLaunchGameModeChooserIdentifier
                     , sender: nil)
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

extension LauncherViewController {
    struct UIDesign {
        static let SegueLaunchGameModeChooserIdentifier = "launchGameModeChooser"
    }
    struct UIParameter {
        #if DEBUG
        static let ParticlesNumber = 0
        static let ParticlesAnimationDuration : TimeInterval = 0
        static let MaximumDelayByParticle : TimeInterval = 0
        static let ParticlesAnimationDelay : TimeInterval = 0
        #else
        static let ParticlesNumber = 30
        static let ParticlesAnimationDuration : TimeInterval = 6
        static let MaximumDelayByParticle : TimeInterval = 2
        static let ParticlesAnimationDelay : TimeInterval = 1
        #endif
    }
}
