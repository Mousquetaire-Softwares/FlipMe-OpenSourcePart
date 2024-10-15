//
//  WeakWrapper.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 29/01/2024.
//

import Foundation

@propertyWrapper
class Weak<Element> where Element:AnyObject {
    weak var wrappedValue : Element?
    
    init(wrappedValue: Element?) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
struct WeakArray<Element> where Element:AnyObject {
    private var realValue : [Weak<Element>]
    
    var wrappedValue : [Element?] {
        get { return realValue.map { $0.wrappedValue } }
        set { realValue = newValue.map { Weak(wrappedValue:$0) } }
    }
    
    init(wrappedValue: [Element?]) {
        self.realValue = wrappedValue.map { Weak(wrappedValue:$0) }
    }
}

