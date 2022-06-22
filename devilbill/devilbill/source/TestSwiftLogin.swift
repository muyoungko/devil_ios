//
//  TestSwiftLogin.swift
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/25.
//

import Foundation

@objc class TestSwiftLogin: NSObject {
    @objc override init() {
        super.init()
    }
    
    @objc class func create() -> TestSwiftLogin {
        return TestSwiftLogin()
    }
    
    @objc func run() {
        print("test function")
    }
}
