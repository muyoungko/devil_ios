# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '14.0'

#use_frameworks!
#use_modular_headers!
use_frameworks! :linkage => :static

inhibit_all_warnings!

workspace 'devil'
project 'devil.xcodeproj'
project 'devilcore/devilcore.xcodeproj'
project 'devillogin/devillogin.xcodeproj'
project 'devilbill/devilbill.xcodeproj'
project 'devilads/devilads.xcodeproj'

def google_ads
  pod 'Google-Mobile-Ads-SDK'
end

def google_signin
  pod 'GoogleSignIn'
end

def lottie_libs
  pod 'lottie-ios', '~> 2.5.3'
end

target 'devil' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  project 'devil.xcodeproj'
  
  lottie_libs
  google_ads
  
  pod 'AFNetworking','~>4.0'
  
  pod 'FirebaseMessaging'
  pod 'FirebaseAuth'
  pod 'FirebaseAnalytics'
  pod 'FirebaseDynamicLinks'
  pod 'FirebaseCrashlytics'
  
  google_signin
  
  pod 'Google-Mobile-Ads-SDK'
  pod 'naveridlogin-sdk-ios'
end


target 'devilcore' do
  project 'devilcore/devilcore.xcodeproj'
  lottie_libs
  pod 'MQTTClient'
  pod 'ZXingObjC', '~> 3.2.1'
  pod 'Charts', '~> 4.1.0'
end

target 'devillogin' do
  project 'devillogin/devillogin.xcodeproj'
  
  lottie_libs
  pod 'Alamofire'
  
#  pod 'KakaoSDK'  # 전체 추가 방식
  pod 'KakaoSDKCommon', '2.11.3'  # 필수 요소를 담은 공통 모듈
  pod 'KakaoSDKAuth', '2.11.3'  # 사용자 인증
  pod 'KakaoSDKUser', '2.11.3'  # 카카오 로그인, 사용자 관리
  pod 'KakaoSDKTalk', '2.11.3'  # 친구, 메시지(카카오톡)
  pod 'KakaoSDKStory', '2.11.3'  # 카카오스토리
#  pod 'KakaoSDKLink', '2.11.3'  # 메시지(카카오톡 공유)
  
#  pod 'FBSDKLoginKit'
#  pod 'FBSDKShareKit'
  
  google_signin
end
  
#target 'devilhealth' do
#  project 'devilhealth/devilhealth.xcodeproj'
#end

target 'devilnfc' do
  project 'devilnfc/devilnfc.xcodeproj'
end

target 'devilextra' do
  project 'devilextra/devilextra.xcodeproj'
end

target 'devilbill' do
  project 'devilbill/devilbill.xcodeproj'
  pod 'TossPayments'
end

target 'devilwebrtc' do
  project 'devilwebrtc/devilwebrtc.xcodeproj'
  pod 'AWSCognitoIdentityProvider'
  pod 'AWSMobileClient'
  pod 'CommonCryptoModule'
  pod 'AWSKinesisVideo'
  pod 'AWSKinesisVideoSignaling'
#  pod 'GoogleWebRTC', '~> 1.1'
  pod 'Starscream', '~> 3.0'
end

#target 'devilads' do
#  project 'devilads/devilads.xcodeproj'
##  google_ads # 이걸 넣으면, 아카이브에서 오류남, GoogleUtilities가 Firebase와 중복됨
#end
