//
//  FoundationExtensions.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 04/10/2023.
//

import Foundation

extension Int {
    var arc4random:Int {
        if self > 0 {
            return Self(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Self(arc4random_uniform(UInt32(-self)))
        } else {
            return 0
        }
    }
    var zeroIfNegative:Int {
        if self < 0 {
            return 0
        } else {
            return self
        }
    }
}

extension Float {
    var zeroIfNegative:Float {
        if self < 0 {
            return 0
        } else {
            return self
        }
    }
}

extension Dictionary where Value : Collection {
    var allValues : [Value.Element] {
        self.flatMap{ $0.value }
    }
}

extension Set where Element : Collection {
    var allValues : [Element.Element] {
        self.flatMap{ $0 }
    }
}

extension Collection {
    subscript(safelyIndex i: Index) -> Element? {
        get {
            guard self.indices.contains(i) else { return nil }
            return self[i]
        }
    }
}
