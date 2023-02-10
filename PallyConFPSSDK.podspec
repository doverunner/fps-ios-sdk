Pod::Spec.new do |s|
  s.name  = 'PallyConFPSSDK'
  s.version = 'v1.17.1a'
  s.platform = :ios
  s.summary = 'PallyConDrm SDK for iOS'
  s.author = { 'InkaEntworks' => 'yhpark@inka.co.kr' }
  s.homepage = 'https://github.com/inka-pallycon/pallycon-fps-ios-sdk'
  s.source = {
    :git => 'https://github.com/inka-pallycon/pallycon-fps-ios-sdk',
    :tag => 'v1.17.1a'
  }
  s.vendored_frameworks = 'lib/PallyConFPSSDK.xcframework'
end
