Pod::Spec.new do |s|
  s.name             = 'PlayKitSmartSwitch'
  s.version          = '1.0.0'
  s.summary          = 'Kaltura PlayKit plugin for the NPAW Smart Switch.'
  
  s.description      = <<-DESC
  Kaltura PlayKit plugin for the NPAW Smart Switch.
  https://npaw.com/cdn-balancer/
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
  
  s.xcconfig = {
### The following is required for Xcode 12 (https://stackoverflow.com/questions/63607158/xcode-12-building-for-ios-simulator-but-linking-in-object-file-built-for-ios)
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64'
  }
  
end
