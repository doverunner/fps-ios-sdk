Pod::Spec.new do |s|
  s.name  = 'DoveRunnerFairPlay'
  s.version = '2.7.2'
  s.platform = :ios
  s.ios.deployment_target = '15.0'
  s.summary = 'DoveRunner FairPlay SDK for iOS'
  s.author = { 'DoveRunner Multi-DRM' => 'support@doverunner.com' }
  s.homepage = 'https://github.com/doverunner/fps-ios-sdk'
  s.license = { :type => 'Commercial', :text => 'Copyright (c) DoveRunner. All rights reserved.' }
  s.source = {
    :git => 'https://github.com/doverunner/fps-ios-sdk.git',
    :tag => s.version.to_s
  }
  s.vendored_frameworks = 'lib/DoveRunnerFairPlay.xcframework'
  s.swift_versions = '5.0'

  s.user_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }

end