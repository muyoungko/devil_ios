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

@objc
public class KakaoWrapper: NSObject {
    @objc public override init() {
        super.init()
    }
 
    @objc static public func initKakaoAppKey() {
        KakaoSDKCommon.initSDK(appKey: "d0c7657dc3cd93575cc590b87c0dc624")
    }
    
    @objc public func login() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                }
            }
        }
    }
    
    @objc public func logout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
    }
}
