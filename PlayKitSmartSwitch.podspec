Pod::Spec.new do |s|
  s.name             = 'PlayKitSmartSwitch'
  s.version          = '0.0.1'
  s.summary          = 'Kaltura PlayKit plugin for the NPAW Smart Switch.'
  
  s.description      = <<-DESC
  Kaltura PlayKit plugin for the NPAW Smart Switch.
  DESC
  
  s.homepage         = 'https://github.com/kaltura/playkit-ios-smartSwitch'
  s.license          = { :type => 'AGPLv3', :file => 'LICENSE' }
  s.author           = { 'Kaltura' => 'community@kaltura.com' }
  s.source           = { :git => 'https://github.com/kaltura/playkit-ios-smartSwitch.git', :tag => s.version.to_s }
  
  s.swift_version     = '5.0'
  
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  
  s.source_files = 'PlayKitSmartSwitch/Classes/**/*'
  
  s.dependency 'PlayKit/AnalyticsCommon', '~> 3.22'
  s.dependency 'KalturaPlayer/Interceptor'
  s.dependency 'KalturaNetKit', '~> 1.5.1'
end
