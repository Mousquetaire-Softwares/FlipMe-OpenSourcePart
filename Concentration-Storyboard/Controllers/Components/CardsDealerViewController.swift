//
//  CardsDealerViewController.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 23/11/2023.
//

import UIKit

protocol CardsDealerViewControllerDelegate : AnyObject {
    func addCards()
}

class CardsDealerViewController: UIViewController {
    
    weak var delegate : CardsDealerViewControllerDelegate?
    private var cardViewControllers : [CardViewController] = []
    
    @IBOutlet weak var squaredView: UIView! {
        didSet {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOfSquaredView(sender:)))
            gestureRecognizer.delaysTouchesEnded = false
            gestureRecognizer.cancelsTouchesInView = false
            
            self.squaredView.addGestureRecognizer(gestureRecognizer)
        }
    }
    @objc private func handleTapOfSquaredView(sender:UITapGestureRecognizer) {
        addingCardsAnimation()
        delegate?.addCards()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0..<10 {
            
            let newCardVC = PresentationCardViewController(roundedAngleFactorAtCreation: 0.3)
            
            newCardVC.view.isUserInteractionEnabled = false
            cardViewControllers.append(newCardVC)
            addChild(newCardVC)
            
            self.squaredView.addSubview(newCardVC.view)
            NSLayoutConstraint.activate(
                [
                    newCardVC.view.widthAnchor.constraint(equalTo: self.squaredView.widthAnchor, multiplier: UIParameter.CardViewToSquaredView)
                    ,newCardVC.view.heightAnchor.constraint(equalTo: self.squaredView.heightAnchor, multiplier: UIParameter.CardViewToSquaredView)
                ]
            )
            // random constraint between 3 positions in both axes
            self.squaredView.addConstraint(
                [
                    newCardVC.view.leadingAnchor.constraint(equalTo: self.squaredView.leadingAnchor)
                    ,newCardVC.view.centerXAnchor.constraint(equalTo: self.squaredView.centerXAnchor)
                    ,newCardVC.view.trailingAnchor.constraint(equalTo: self.squaredView.trailingAnchor)
                ].randomElement()!
            )
            self.squaredView.addConstraint(
                [
                    newCardVC.view.topAnchor.constraint(equalTo: self.squaredView.topAnchor)
                    ,newCardVC.view.centerYAnchor.constraint(equalTo: self.squaredView.centerYAnchor)
                    ,newCardVC.view.bottomAnchor.constraint(equalTo: self.squaredView.bottomAnchor)
                    
                ].randomElement()!
            )
            
            newCardVC.didMove(toParent: self)
            
            newCardVC.isVisible = true
        }
    }

    func addingCardsAnimation() {
        UIView.animate(withDuration: UIParameter.AnimationDuration
                       ,delay: 0
                       ,options:[.allowUserInteraction]
                       ,animations: { self.view.transform = self.view.transform.scaledBy(x: UIParameter.AnimationScaleFactor, y: UIParameter.AnimationScaleFactor) }
                       , completion: { finished in
            if finished {
                UIView.animate(withDuration: UIParameter.AnimationDuration
                               ,delay: 0
                               ,options:[.allowUserInteraction]
                               ,animations: { self.view.transform = .identity }
                )
            }
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

extension CardsDealerViewController {
    struct UIParameter {
        static let CardViewToSquaredView = 0.7
        static let AnimationScaleFactor = 0.7
        static let AnimationDuration = 0.1
    }
}
