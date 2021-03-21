# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.3'

use_frameworks!
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
 
  pod 'GoogleSignIn', '~> 5.0'
  pod 'GoogleToolboxForMac'
  pod 'AFNetworking','~>4.0'
  
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
  
  pod 'FacebookSDK'
  pod 'FacebookSDK/LoginKit'
  pod 'FacebookSDK/ShareKit'
#  pod 'Bolts'
  
  pod 'Google-Mobile-Ads-SDK'
end


target 'devilcore' do
  project 'devilcore/devilcore.xcodeproj'
  
  lottie_libs
end

target 'devillogin' do
  project 'devillogin/devillogin.xcodeproj'
  
  lottie_libs
  
  pod 'KakaoSDK'
end
  
