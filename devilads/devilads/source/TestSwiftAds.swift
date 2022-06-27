//
//  TestSwiftAds.swift
//  devilads
//
//  Created by Mu Young Ko on 2021/03/25.
//

import Foundation

@objc class TestSwiftAds: NSObject {
    @objc override init() {
        super.init()
    }
    
    @objc class func create() -> TestSwiftAds {
        return TestSwiftAds()
    }
    
    @objc func run() {
        print("test function")
    }
}
