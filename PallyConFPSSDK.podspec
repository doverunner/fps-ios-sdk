Pod::Spec.new do |s|
  s.name  = 'PallyConFPSSDK'
  s.version = '1.17.3'
  s.platform = :ios
  s.ios.deployment_target = "11.2"
  s.summary = 'PallyConDrm SDK for iOS'
  s.author = { 'InkaEntworks' => 'yhpark@inka.co.kr' }
  s.homepage = 'https://github.com/inka-pallycon/pallycon-fps-ios-sdk'
  s.source = {
    :git => 'https://github.com/inka-pallycon/pallycon-fps-ios-sdk.git',
    :tag => 'v1.17.3'
  }
  s.vendored_frameworks = 'lib/PallyConFPSSDK.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => "i386" }
  s.swift_version = '5.0'
end
