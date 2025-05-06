Pod::Spec.new do |s|
  s.name             = 'devilcore'
  s.platform         = :ios
  s.version          = '0.0.297'
  s.summary          = 'Devil Core'
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
  
  s.static_framework = true
  s.source_files = 'devilcore/devilcore/source/**/*.*', 'devilcore/devilcore/header/**/*.h'
  s.public_header_files = 'devilcore/devilcore/source/**/*.h', '"${DERIVED_SOURCES_DIR}/*-Swift.h'
  s.dependency 'lottie-ios'
  s.dependency 'MQTTClient'
  s.dependency 'ZXingObjC', '~> 3.6.9'
  s.dependency 'Charts', '~> 4.1.0'
  s.dependency 'GoogleMaps', '7.3.0'
  s.resources = 'devilcore/devilcore/resource/*'

end
