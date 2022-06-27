//
//  DevilKakaoLogin.swift
//  devillogin
//
//  Created by Mu Young Ko on 2021/03/22.
//

import Foundation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@objc
public class DevilKakaoLogin: NSObject {
    @objc public override init() {
        super.init()
    }
 
    @objc static public func initKakaoAppKey() {
        let path = Bundle.main.path(forResource: "devil", ofType:"plist")!
        let dict = NSDictionary(contentsOfFile: path)
        
        KakaoSDK.initSDK(appKey: dict!["KakaoAppKey"] as! String)
    }
    
    @objc static public func handleOpenUrl(_ url:URL) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
           return AuthController.handleOpenUrl(url: url)
       }
       return false
    }
    
    @objc public func updateProfile(completion:@escaping (Any?)->()) {
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            }
            else {
                print("me() success.")

                //do something
                _ = user?.id
                
                let r: NSMutableDictionary = NSMutableDictionary()
                r["profile"] = user?.kakaoAccount?.profile?.thumbnailImageUrl?.absoluteString
                completion(r)
            }
        }
    }
    
    @objc public func login(completion:@escaping (Any?)->()) {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                    completion(nil)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                    self.getProfile { (user) in
                        completion(user)
                    }
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
               if let error = error {
                 print(error)
               }
               else {
                print("loginWithKakaoAccount() success.")
                _ = oauthToken
                self.getProfile { (user) in
                    completion(user)
                }
               }
            }
        }
    }
    
    @objc public func getProfile(completion:@escaping (Any?)->()) {
        UserApi.shared.accessTokenInfo {(accessTokenInfo, error) in
            if let error = error {
                print(error)
                completion(nil)
            }
            else {
                print("accessTokenInfo() success.")

                //do something
                _ = accessTokenInfo
                UserApi.shared.me() {(user, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("me() success.")

                        //do something
                        _ = user?.id
                        
                        let r: NSMutableDictionary = NSMutableDictionary()
                        //r["id"] = String(describing:user?.id)
                        r["identifier"] = String(format: "%d", user?.id as! CVarArg)
                        r["name"] = user?.kakaoAccount?.profile?.nickname
                        r["profile"] = user?.kakaoAccount?.profile?.thumbnailImageUrl?.absoluteString
                        r["email"] = user?.kakaoAccount?.email
                        r["age_range"] = user?.kakaoAccount?.ageRange?.rawValue
                        r["gender"] = user?.kakaoAccount?.gender?.rawValue
                        r["token"] = TokenManager.manager.getToken()!.accessToken;
                        completion(r)
                    }
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
