//
//  FictiveGametableRepresentationView.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 27/02/2024.
//

import UIKit

/// Construct a view to represent a gametable with a given number of cards, filled in square
/// Each card is represented as a simple card icon - could be just a colored square, or an image...
class FictiveGametableRepresentationView: UIView {

    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    //common func to init our view
    private func setupView() {
        backgroundColor = .clear
    }
    
    var numberOfCards : Int = 0 {
        didSet {
            if oldValue != numberOfCards {
                updateNumberOfCards()
            }
        }
    }
    
    private lazy var masterStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .top
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubviewFullsized(stackView)
        stackView.isOpaque = false
        stackView.spacing = 4
        return stackView
    }()
    
    private var subVerticalStackViews : [UIStackView] {
        return masterStackView.arrangedSubviews.compactMap{ $0 as? UIStackView }
    }
    private func createNewVerticalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isOpaque = false
        stackView.spacing = 4
        return stackView
    }
    
    private var matrixSize : Size2D {
        return Size2D(rows: subVerticalStackViews.reduce(0) {
            max($0,$1.subviews.count) }
                      , columns: subVerticalStackViews.count)
    }
    
    private func addColumnInMatrix() {
        let newStackView = createNewVerticalStackView()
        masterStackView.addArrangedSubview(newStackView)
        for _ in 0..<matrixSize.rows {
            createNewCardIcon(in:newStackView)
        }
    }
    private func addRowInMatrix() {
        subVerticalStackViews.forEach{
            createNewCardIcon(in:$0)
        }
    }
    
    private func cardIcon(at location: Location2D) -> UIView {
        if case let columnsToAdd = (location.column+1 - matrixSize.columns), columnsToAdd > 0 {
            for _ in 1...columnsToAdd {
                addColumnInMatrix()
            }
        }
        if case let rowsToAdd = (location.row+1 - matrixSize.rows), rowsToAdd > 0 {
            for _ in 1...rowsToAdd {
                addRowInMatrix()
            }
        }
        return subVerticalStackViews[location.column].arrangedSubviews[location.row]
    }
    
    private func makeCardIconVisible(at location: Location2D) {
        let cardIconView = cardIcon(at: location)
        subVerticalStackViews[location.column].isHidden = false
        subVerticalStackViews.forEach{
            $0.arrangedSubviews[location.row].isHidden = false
        }
        cardIconView.alpha = 1
    }
    
    private func makeAllCardIconsInvisible() {
        subVerticalStackViews.forEach{ $0.isHidden = true }
        subVerticalStackViews.forEach{
            $0.arrangedSubviews.forEach{
                $0.isHidden = true
                $0.alpha = 0
            }
        }
    }
    
    private func createNewCardIcon(in container:UIStackView) {
        let newView = FictiveCardView()

        newView.isHidden = true
        newView.alpha = 0
        
        container.addArrangedSubview(newView)
    }
    
    private func updateNumberOfCards() {
        makeAllCardIconsInvisible()
        
        var location = Location2D(row: 0, column: 0)
        
        var columns = 0, rows = 0
        for _ in 0..<numberOfCards {
            makeCardIconVisible(at: location)
            
            if location.column == columns && location.row == rows {
                if rows < columns {
                    rows += 1
                    location = Location2D(row: rows, column: 0)
                } else {
                    columns += 1
                    location = Location2D(row: 0, column: columns)
                }
            } else if location.column < columns {
                location = Location2D(row: location.row, column: location.column+1)
            } else {
                location = Location2D(row: location.row+1, column: location.column)
            }
        }
    }

}
