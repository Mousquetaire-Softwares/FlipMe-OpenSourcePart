//
//  GameDynamicView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 03/07/2023.
//

import UIKit

class GametableView: UIView {

    // MARK: managing cards
    @IBOutlet weak var masterStackView: UIStackView!
    
    var subStackViews : [UIStackView] {
        return masterStackView?.arrangedSubviews.filter{ $0 is UIStackView }.map{ $0 as! UIStackView } ?? []
    }
    
//    private weak var subStackView1: UIStackView?
    
    func configureNewVerticalStackView() -> UIStackView {
        let newStackView = UIStackView()
        newStackView.distribution = .fillEqually
        newStackView.spacing = masterStackView.spacing
        newStackView.backgroundColor = subStackViews.first?.backgroundColor
        newStackView.axis = .vertical
        newStackView.translatesAutoresizingMaskIntoConstraints = false
        return newStackView
    }
    
    // convenient properties : cells dictionary, size of matrix...
    private(set) lazy var cells : [Location2D:UIView] = generateCellsDictionary()
    var matrixSize : Size2D {
        Size2D(rows: subStackViews.first?.arrangedSubviews.count ?? 0, columns: subStackViews.count)
    }
    
    private func updateCellsDictionary() {
        cells = generateCellsDictionary()
    }
    private func generateCellsDictionary() -> [Location2D:UIView] {
        var result = [Location2D:UIView]()
        subStackViews.enumerated().forEach{
            verticalStackIndexValue in
            let columnIndex = verticalStackIndexValue.offset
            for cellIndexValue in verticalStackIndexValue.element.arrangedSubviews.enumerated() {
                let location = Location2D(row: cellIndexValue.offset, column: columnIndex)
                result[location] = cellIndexValue.element
            }
        }
        return result
    }

    public func getExpandingDirection(remainingCardsToAdd:Int? = nil) -> GametableExpandingDirection {
        
        func getExpandingDirectionByFreeSpaceInBounds() -> GametableExpandingDirection {
            layoutIfNeeded()
            let freeHorizontalSpace = bounds.width - masterStackView.bounds.width
            let freeVerticalSpace = bounds.height - masterStackView.bounds.height
            return freeHorizontalSpace >= freeVerticalSpace ? .column : .row
        }
        
        if let remainingCardsToAdd, remainingCardsToAdd > 0 {
            if matrixSize.rows >= remainingCardsToAdd && matrixSize.columns < remainingCardsToAdd {
                return .column
            } else if matrixSize.columns >= remainingCardsToAdd && matrixSize.rows < remainingCardsToAdd {
                return .row
            } else if matrixSize.columns >= remainingCardsToAdd && matrixSize.rows >= remainingCardsToAdd {
                if matrixSize.rows < matrixSize.columns {
                    return .column
                } else {
                    return .row
                }
            } else {
                return getExpandingDirectionByFreeSpaceInBounds()
            }
        } else {
            return getExpandingDirectionByFreeSpaceInBounds()
        }
    }
    
    public func addColumn() -> [Location2D:UIView] {
        var result = [Location2D:UIView]()
        let newVerticalStack = configureNewVerticalStackView()
        
        if let firstVerticalStack = subStackViews.first {
            let columnIndex = subStackViews.count
            for rowIndex in firstVerticalStack.arrangedSubviews.indices {
                let newLocation = Location2D(row: rowIndex, column: columnIndex)
                let newView = UIView()
                newVerticalStack.addArrangedSubview(newView)
                result[newLocation] = newView
            }
        }
        masterStackView.addArrangedSubview(newVerticalStack)
        updateCellsDictionary()
        return result
    }
    public func addRow() -> [Location2D:UIView] {
        var result = [Location2D:UIView]()
        
        let rowIndex = subStackViews.first?.arrangedSubviews.count ?? 0
        subStackViews.enumerated().forEach{
            let columnIndex = $0.offset
            let newLocation = Location2D(row: rowIndex, column: columnIndex)
            let newView = UIView()
            $0.element.addArrangedSubview(newView)
            result[newLocation] = newView
        }
        updateCellsDictionary()
        return result
    }
    
    public func expandByRowOrColumn() -> [Location2D:UIView] {
        switch (getExpandingDirection()) {
        case .column: return addColumn()
        case .row: return addRow()
        }
    }
    
    
    func rotateMatrix(clockwise:Bool) {

        var invertOrderOfSubStacks : Bool = false
        var invertOrderOfCellsInSubStacks : Bool = true
        switch(masterStackView.axis) {
        case .horizontal:
            invertOrderOfSubStacks = false
            invertOrderOfCellsInSubStacks = true
        case .vertical:
            invertOrderOfSubStacks = true
            invertOrderOfCellsInSubStacks = false
        @unknown default:
            break
        }
        
        if clockwise == false {
            invertOrderOfSubStacks = !invertOrderOfSubStacks
            invertOrderOfCellsInSubStacks = !invertOrderOfCellsInSubStacks
        }
        
        var subStackViews = subStackViews

        // necessary for stackview because it may not be empty for this function to work
        let emptyView = UIView()
        masterStackView.addArrangedSubview(emptyView)
        
        subStackViews.enumerated().forEach{
            addSubview($0.element)
            masterStackView.removeArrangedSubview($0.element)
            $0.element.axis.invert()
            if invertOrderOfCellsInSubStacks {
                $0.element.reverseArrangedSubviews()
            }
        }
        masterStackView.axis.invert()
        
        if invertOrderOfSubStacks {
            subStackViews.reverse()
        }
        subStackViews.enumerated().forEach{
            masterStackView.addArrangedSubview($0.element)
        }
        masterStackView.removeArrangedSubview(emptyView)
        emptyView.removeFromSuperview()

    }
    
}

extension NSLayoutConstraint.Axis {
    mutating func invert() {
        switch(self) {
        case .vertical: self = .horizontal
        case .horizontal:  self = .vertical
        @unknown default:
            break
        }
    }
}

extension UIStackView {
    func reverseArrangedSubviews() {
        let subviews = arrangedSubviews.reversed()
        for subview in subviews {
            addArrangedSubview(subview)
        }
                
    }
}
