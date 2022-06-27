Pod::Spec.new do |s|
  s.name             = 'devil'
  s.platform         = :ios
  s.version          = '0.0.164'
  s.summary          = 'Devil Core'
  s.description      = <<-DESC
    This is Devil
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
  
  s.subspec 'DevilCore' do |ss|
    ss.dependency 'devilcore', '~> 0.0.161'
  end

  s.subspec 'DevilLogin' do |ss|
    ss.dependency 'devillogin', '~> 0.0.161'
  end
  
  s.subspec 'DevilAds' do |ss|
    ss.dependency 'devilads', '~> 0.0.161'
  end
  
  s.subspec 'DevilBill' do |ss|
    ss.dependency 'devilbill', '~> 0.0.161'
  end

end
