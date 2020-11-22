Pod::Spec.new do |s|
  s.name             = 'devil'
  s.version          = '0.0.1'
  s.summary          = 'Devil Core'
  s.description      = <<-DESC
    Devil Core
                       DESC
  s.homepage         = 'https://github.com/muyoungko/devil_ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'muyoungko' => 'muyoungko@gmail.com' }
  s.source           = { :git => 'https://github.com/muyoungko/devil_ios.git', :tag => s.version.to_s }
  #s.ios.deployment_target = '8.0'
  #s.source_files = 'devilcore/devilcore/*.*'
  
  s.subspec 'DevilCore' do |devilCore|
    # devilCore.dependency 'Alamofire'
    devilCore.source_files = 'devilcore/devilcore/*.*'
    # s.resources = 'Pod/Assets/*'
  end

  #s.subspec 'DevilLogin' do |devilLogin|
  #  devilLogin.dependency 'devil/DevilCore'
  #  devilLogin.source_files = 'devilcore/devilcore/*.*'
  #end

end
