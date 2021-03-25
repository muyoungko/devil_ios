//
//  Test.swift
//  devil
//
//  Created by Mu Young Ko on 2021/03/25.
//  Copyright © 2021 Mu Young Ko. All rights reserved.
//

import Foundation

@objc class Test: NSObject {
    @objc override init() {
        super.init()
    }
    
    @objc class func create() -> Test {
        return Test()
    }
    
    @objc func run() {
        print("test function")
    }
}
