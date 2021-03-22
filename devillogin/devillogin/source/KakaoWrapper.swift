//
//  KakaoWrapper.swift
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/22.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@objc class KakaoWrapper: NSObject {
    @objc func run() {
        print("test function")
    }
    
    @objc func login() {
        UserApi.shared.loginWithKakaoAccount(prompts:[.Login]) {(oauthToken, error) in
            if let error = error {
                print(error)
            }
            else {
                print("loginWithKakaoAccount() success.")

                //do something
                _ = oauthToken

            }
        }
    }
}
