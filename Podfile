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
  pod 'GoogleSignIn', '~> 5.0'
  pod 'GoogleToolboxForMac'
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
  
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Crashlytics'
  
  google_signin
  
  pod 'Google-Mobile-Ads-SDK'
  pod 'naveridlogin-sdk-ios'
end


target 'devilcore' do
  project 'devilcore/devilcore.xcodeproj'
  lottie_libs
  pod 'MQTTClient'
  pod 'ZXingObjC', '~> 3.2.1'
end

target 'devillogin' do
  project 'devillogin/devillogin.xcodeproj'
  
  lottie_libs
  pod 'Alamofire'
  
  pod 'KakaoSDKCommon'  # 필수 요소를 담은 공통 모듈
  pod 'KakaoSDKAuth'  # 사용자 인증
  pod 'KakaoSDKUser'  # 카카오 로그인, 사용자 관리
  pod 'KakaoSDKTalk'  # 친구, 메시지(카카오톡)
  pod 'KakaoSDKStory'  # 카카오스토리
  pod 'KakaoSDKLink'  # 메시지(카카오톡 공유)
  
  pod 'FBSDKLoginKit', '~> 9.3.0'
  pod 'FBSDKShareKit', '~> 9.3.0'
  
  google_signin
end
  
#target 'devilbill' do
#  project 'devilbill/devilbill.xcodeproj'
#end
#
#target 'devilads' do
#  project 'devilads/devilads.xcodeproj'
##  google_ads # 이걸 넣으면, 아카이브에서 오류남, GoogleUtilities가 Firebase와 중복됨
#end
