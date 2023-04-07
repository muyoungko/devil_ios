Pod::Spec.new do |s|
  s.name             = 'devillogin'
  s.platform         = :ios
  s.version          = '0.0.218'
  s.summary          = 'Devil Login'
  s.description      = <<-DESC
    This is Devil Login
                       DESC
  s.homepage         = 'https://github.com/muyoungko/devil_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'muyoungko' => 'muyoungko@gmail.com' }
  s.source           = { :git => 'https://github.com/muyoungko/devil_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.3'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"'
  }
  
  s.source_files = 'devillogin/devillogin/source/**/*.*', 'devillogin/devillogin/header/**/*.h'
  s.public_header_files = 'devillogin/devillogin/source/**/*.h', '"${DERIVED_SOURCES_DIR}/*-Swift.h'
  s.static_framework = true
  s.dependency 'devilcore', '~> 0.0.187'
  s.dependency 'Alamofire'
  
  s.dependency 'KakaoSDKCommon', '2.11.3'
  s.dependency 'KakaoSDKAuth', '2.11.3'
  s.dependency 'KakaoSDKUser', '2.11.3'
  s.dependency 'KakaoSDKTalk', '2.11.3'
  s.dependency 'KakaoSDKStory', '2.11.3'
  #s.dependency 'KakaoSDKLink'
        
  #s.dependency 'FBSDKLoginKit', '~> 9.3.0'
  #s.dependency 'FBSDKShareKit', '~> 9.3.0'
  #s.dependency 'GoogleSignIn'
  #s.dependency 'GoogleToolboxForMac'

end
