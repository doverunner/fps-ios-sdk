Pod::Spec.new do |s|
  s.name  = 'DoveRunnerFairPlay'
  s.version = '2.5.0'
  s.platform = :ios
  s.ios.deployment_target = '12.0'
  s.summary = 'DoveRunner FairPlay SDK for iOS'
  s.author = { 'DoveRunner' => 'support' }
  s.homepage = 'https://github.com/doverunner/fps-ios-sdk'
  s.source = {
    :git => 'https://github.com/doverunner/fps-ios-sdk.git',
    :tag => 'v2.5.0'
  }
  s.vendored_frameworks = 'lib/DoveRunnerFairPlay.xcframework'
  s.swift_versions = '5.0'

  s.user_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end