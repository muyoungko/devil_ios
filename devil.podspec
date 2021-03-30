Pod::Spec.new do |s|
  s.name             = 'devil'
  s.platform         = :ios
  s.version          = '0.0.59'
  s.summary          = 'Devil Core'
  s.description      = <<-DESC
    This is Devil Core
                       DESC
  s.homepage         = 'https://github.com/muyoungko/devil_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'muyoungko' => 'muyoungko@gmail.com' }
  s.source           = { :git => 'https://github.com/muyoungko/devil_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.3'
      
  s.subspec 'DevilCore' do |devilCore|
    devilCore.source_files = 'devilcore/devilcore/source/**/*.*'
    devilCore.public_header_files = 'devilcore/devilcore/source/**/*.h'
    devilCore.resources = 'devilcore/devilcore/resource/*'
    devilCore.dependency 'lottie-ios', '~> 2.5.3'
    #devilCore.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
    #devilCore.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PROJECT_DIR}/.."/**' }
  end

  s.subspec 'DevilLogin' do |devilLogin|
    devilLogin.source_files = 'devillogin/devillogin/source/**/*.*'
    devilLogin.public_header_files = 'devillogin/devillogin/source/**/*.h'
    devilLogin.dependency 'devil/DevilCore'
    devilLogin.dependency 'KakaoSDK'
    devilLogin.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
    #devilLogin.xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PROJECT_DIR}/.."/**' }
    #devilLogin.pod_target_xcconfig = { 'USER_HEADER_SEARCH_PATHS' => '"${PROJECT_DIR}/.."/**' }
    #devilLogin.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '$(PODS_ROOT)/mypod/module' }
    #devilLogin.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2 $(PODS_ROOT)/mypod/module' }
  end

end
