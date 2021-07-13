# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.3'

#use_frameworks!
#use_modular_headers!
use_frameworks! :linkage => :static

inhibit_all_warnings!

workspace 'devil'
project 'devil.xcodeproj'
project 'devilcore/devilcore.xcodeproj'
project 'devillogin/devillogin.xcodeproj'

def lottie_libs
  pod 'lottie-ios', '~> 2.5.3'
end

target 'devil' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  project 'devil.xcodeproj'
  
  lottie_libs
 
  pod 'AFNetworking','~>4.0'
  
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  
  pod 'GoogleSignIn', '~> 5.0'
  pod 'GoogleToolboxForMac'
  pod 'Google-Mobile-Ads-SDK'
  pod 'naveridlogin-sdk-ios'
end


target 'devilcore' do
  project 'devilcore/devilcore.xcodeproj'
  # pod "NextLevel", "~> 0.16.3"
  lottie_libs
  pod 'MQTTClient'
end

target 'devillogin' do
  project 'devillogin/devillogin.xcodeproj'
  
  lottie_libs
  
  pod 'KakaoSDK'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'GoogleSignIn', '~> 5.0'
  pod 'GoogleToolboxForMac'
end
  
