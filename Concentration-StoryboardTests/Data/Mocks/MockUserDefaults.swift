//
//  MockUserDefaults.swift
//  Concentration-StoryboardTests
//
//  Created by Steven Morin on 22/04/2024.
//

import Foundation

class MockUserDefaults : UserDefaults {
    convenience init() {
        self.init(suiteName: "MockUserDefaults")!
    }
    
    override init?(suiteName suitename: String?) {
        UserDefaults().removePersistentDomain(forName: suitename!)
        super.init(suiteName: suitename)
    }
}
