//
//  StagesCollectionView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 18/03/2024.
//

import UIKit

class StagesCollectionContainerView: UIView {
    
    // Special rule for hitTest here is : we want to catch touch events anywhere in the window, for collectionView scrolling to work everywhere on screen
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Standard behaviour of hitTest in UIKit
        guard isUserInteractionEnabled else { return nil }
        guard !isHidden else { return nil }
        guard alpha >= 0.01 else { return nil }
        
        if let window = self.window
        {
            let pointInWindow = convert(point, to: window)
            if window.bounds.contains(pointInWindow)
                // the collection view is not a direct subview, but a subview of a subview because of a "UICollectionViewControllerWrapperView" inserted by the IB / Storyboard as a subview
                , let collectionView = subviews.first?.subviews.first
            {
                let pointInCollectionView = convert(point, to: collectionView)
                
                // if the touched point is a subview of the collection view, we return it as it is.
                // otherwise, the collection view is the result, to make de scroll work on every other touched point
                if let hitSubview = collectionView.hitTest(pointInCollectionView, with: event) {
                    return hitSubview
                } else {
                    return collectionView
                }
            } else {
                return nil
            }
        } else {
            return hitTest(point, with: event)
        }
    }
}
