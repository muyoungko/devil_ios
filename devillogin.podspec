Pod::Spec.new do |s|
  s.name             = 'devillogin'
  s.platform         = :ios
  s.version          = '0.0.82'
  s.summary          = 'Devil Login'
  s.description      = <<-DESC
    This is Devil Login
                       DESC
  s.homepage         = 'https://github.com/muyoungko/devil_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'muyoungko' => 'muyoungko@gmail.com' }
  s.source           = { :git => 'https://github.com/muyoungko/devil_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.3'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"'
  }
  
  s.source_files = 'devillogin/devillogin/source/**/*.*', 'devillogin/devillogin/header/**/*.h'
  s.public_header_files = 'devillogin/devillogin/source/**/*.h', '"${DERIVED_SOURCES_DIR}/*-Swift.h'
  s.static_framework = true
  s.dependency 'devilcore', '~> 0.0.82'
  s.dependency 'KakaoSDK'
  s.dependency 'FBSDKLoginKit'
  s.dependency 'FBSDKShareKit'
  #s.dependency 'GoogleSignIn'
  #s.dependency 'GoogleToolboxForMac'

end
