Pod::Spec.new do |s|
  s.name             = 'devilcore'
  s.platform         = :ios
  s.version          = '0.0.158'
  s.summary          = 'Devil Core'
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
  
  s.source_files = 'devilcore/devilcore/source/**/*.*', 'devilcore/devilcore/header/**/*.h'
  s.public_header_files = 'devilcore/devilcore/source/**/*.h', '"${DERIVED_SOURCES_DIR}/*-Swift.h'
  s.dependency 'lottie-ios', '~> 2.5.3'
  s.dependency 'MQTTClient'
  s.dependency 'ZXingObjC', '~> 3.2.1'
  s.resources = 'devilcore/devilcore/resource/*'

end
