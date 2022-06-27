//
//  TestSwiftBill.swift
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/25.
//

import Foundation

@objc class TestSwiftBill: NSObject {
    @objc override init() {
        super.init()
    }
    
    @objc class func create() -> TestSwiftBill {
        return TestSwiftBill()
    }
    
    @objc func run() {
        print("test function")
    }
}
