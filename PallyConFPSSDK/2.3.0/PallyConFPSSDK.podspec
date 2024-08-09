Pod::Spec.new do |s|
  s.name  = 'PallyConFPSSDK'
  s.version = '2.3.0'
  s.platform = :ios
  s.ios.deployment_target = '12.0'
  s.summary = 'PallyConDrm SDK for iOS'
  s.author = { 'PallyCon' => 'yhpark@inka.co.kr' }
  s.homepage = 'https://github.com/inka-pallycon/pallycon-fps-ios-sdk'
  s.source = {
    :git => 'https://github.com/inka-pallycon/pallycon-fps-ios-sdk.git',
    :tag => 'v2.3.0'
  }
  s.vendored_frameworks = 'lib/PallyConFPSSDK.xcframework'
  s.swift_versions = '5.10'

  s.user_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

end
