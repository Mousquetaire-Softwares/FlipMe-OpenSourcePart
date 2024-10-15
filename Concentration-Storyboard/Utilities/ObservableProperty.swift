//
//  ObservableProperty.swift
//  Concentration-Storyboard
//
//  Created by Steven Morin on 19/09/2023.
//

import Foundation

final class ObservableProperty<T> {
    typealias Observer = (T) -> Void
    
    private var observers : [Observer] = []
    
    var value : T {
        didSet {
            observers.forEach{ $0(value) }
//            observer?(value)
        }
    }
    
    init(_ value:T, observer: Observer? = nil) {
        if let observer = observer {
            self.observers.append(observer)
        }
        self.value = value
    }
    
    func addObserver(_ observer: @escaping Observer) {
        self.observers.append(observer)
    }
//    public init(_ value:T) {
//        self.value = value
//    }
}
