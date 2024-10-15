//
//  TwoDimensionsFramework.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 17/01/2024.
//

import Foundation

struct Size2D : Equatable {
    var rows, columns : Int
    
    func contains(_ location:Location2D) -> Bool {
        return location.row >= 0 && location.column >= 0 && location.row <= rows && location.column <= columns
    }
    
    
    func getLocationsInNaturalOrder(requestedCount:Int) -> [Location2D] {
        var result = [Location2D]()
        var location = Location2D(row: 0, column: 0)
        
    mainLoop: while location.row < self.rows {
            location.column = 0
            
            while location.column < self.columns {
                result.append(location)
                
                if result.count == requestedCount {
                    break mainLoop
                }
                location.column += 1
            }
            location.row += 1
        }
        return result
    }
    
    var area : Int {
        rows * columns
    }
}

struct Location2D : Equatable, Hashable {
    var row:Int
    var column:Int
}
