Pod::Spec.new do |s|
  s.name             = 'devilwebrtc'
  s.platform         = :ios
  s.version          = '0.0.280'
  s.summary          = 'Devil WebRtc'
  s.description      = <<-DESC
    This is Devil Login
                       DESC
  s.homepage         = 'https://github.com/muyoungko/devil_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'muyoungko' => 'muyoungko@gmail.com' }
  s.source           = { :git => 'https://github.com/muyoungko/devil_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.3'
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}"'
  }
  
  s.source_files = 'devilwebrtc/devilwebrtc/source/**/*.*', 'devilwebrtc/devilwebrtc/header/**/*.h'
  s.public_header_files = 'devilwebrtc/devilwebrtc/source/**/*.h', '"${DERIVED_SOURCES_DIR}/*-Swift.h'
  s.static_framework = true
  s.dependency 'devilcore', '~> 0.0.271'
  s.dependency 'AWSCognitoIdentityProvider'
  s.dependency 'AWSMobileClient'
  s.dependency 'CommonCryptoModule'
  s.dependency 'AWSKinesisVideo'
  s.dependency 'AWSKinesisVideoSignaling'
  s.dependency 'Starscream', '~> 3.0'
  s.dependency 'GoogleWebRTC' 
end
