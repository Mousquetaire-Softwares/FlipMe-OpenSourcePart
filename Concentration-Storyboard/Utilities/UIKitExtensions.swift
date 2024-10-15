//
//  UIKitExtensions.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 30/11/2023.
//

import Foundation
import UIKit


extension UIView {
    func addSubviewFullsized(_ subview:UIView) {
        self.addSubview(subview)
        self.setContraints(toLookLike: subview)
    }
    func insertSubviewFullsized(_ subview:UIView, at index:Int) {
        self.insertSubview(subview, at: index)
        self.setContraints(toLookLike: subview)
    }
    func setContraints(toLookLike otherView: UIView, scaleBy: CGFloat = 1) {
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: otherView.widthAnchor, multiplier: scaleBy)
            ,self.heightAnchor.constraint(equalTo: otherView.heightAnchor, multiplier: scaleBy)
            ,self.centerXAnchor.constraint(equalTo: otherView.centerXAnchor)
            ,self.centerYAnchor.constraint(equalTo: otherView.centerYAnchor)
        ])
    }
    
    func deactivateAllSuperviewsConstraints() {
        func deactivateAllSuperviewsConstraints(startSearchingFrom superview:UIView?) {
            if let superview {
                let constraints = superview.constraints.filter({
                    ($0.firstItem as? UIView) == self || ($0.secondItem as? UIView) == self
                })
                
                NSLayoutConstraint.deactivate(constraints)
                
                deactivateAllSuperviewsConstraints(startSearchingFrom: superview.superview)
            }
        }
        deactivateAllSuperviewsConstraints(startSearchingFrom: superview)
    }
    
    var contents: UIView {
        if subviews.count == 1 {
            return subviews.first!
        } else {
            return self
        }
    }
    
    func transform(toLookLike target:CGRect, fromView:UIView? = nil) {
        self.transform =  self.transform.concatenating(CGAffineTransform.transform(view: self, toLookLike: target, fromView: fromView))
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

extension UIViewController {
    func presentOnRoot(`with` viewController : UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(navigationController, animated: false, completion: nil)
    }
}

public protocol NibLoadable {
    static var nibName: String { get }
}
public extension NibLoadable where Self: UIView {
    static var nibName: String {
        return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
    }
    static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: Self.nibName, bundle: bundle)
    }
    func setupFromNib() {
        guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Error loading \(self) from nib")
        }
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
}
