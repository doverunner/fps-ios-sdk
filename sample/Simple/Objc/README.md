# DoveRunnerFairPlay SDK Ojbective-C Sample
### A simple DoveRunnerFairPlay SDK Objective-C sample

This sample demonstrates how to use the `DoveRunnerFairPlay` framework to play HTTP Live Streams hosted on remote servers as `Objective-C` language.



## Using the Sample

- Samples using the `DoveRunnerFairPlay` SDK  run on real devices and do not work in the simulator.
- In `viewDidLoad()`, initialize `DoveRunnerFairPlay`, set license information in `viewDidAppear()`, and play `AVFoundation`.
- Check `Advanced Sample` to check the usage of various APIs in `DoveRunnerFairPlay`.



### Adding `DoveRunnerFairPlay.xcframework` to the Sample

- Add `DoveRunnerFairPlay.xcframework` to Xcode project target in `General` -> `Embedded Binaries`.
- Add `DoveRunnerFairPlay.xcframework` to the `Build Settings` -> `Search Paths` -> `Framework Search Paths` path.
- Import the SDK header (`ViewController.m`).

    ~~~objectivec
    	#import <DoveRunnerFairPlay/DoveRunnerFairPlay-ObjC.h>
    ~~~



### Adding Streams to the Sample

- If you wish to add your own HLS streams to test with using this sample, you can do this by adding an entry into the `ViewController.m` that is part of the Xcode Project.

	~~~objectivec
   // Service Integration Information
   #define CERTIFICATE_URL     @""
   #define CONTENT_ID          @""
   #define CONTENT_URL         @""
   #define CONTENT_AUTHDATA    @""
	~~~

- \- If you have registered an Apple certificate with DoveRunner Server, please refer to the [DoveRunner Guide](https://doverunner.com/docs/content-security/multi-drm/clients/fairplay-ios/) for the `CERTIFICATE_URL` value.

### Application Transport Security

- If any of the streams you add are not hosted securely, you will need to add an Application Transport Security(ATS) exception in the Info.plist.
- More information on ATS and the relevant plist keys can be found in the following article:
- Information Property List Key Reference - NSAppTransportSecurity: <https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33>



### Bitcode

-  **`iOS`** library does **not support** `Bitcode`.
   - In the Xcode project target `Build Settings` -> `Build Options` -> `Enable Bitcode` to `NO`.
-  **`tvOS`** library **supports** `Bitcode`.



## Main Files

__ViewController.m__: 

- It is the main file to play HLS stream using `DoveRunnerFairPlay` framework.
- Playback is possible by inputting `Service Integration Information` and `Content Information`.



## Multi-DRM Service

Multi-DRM Service description and inquiries are available at the address below.
- [Homepage](https://www.doverunner.com)
- [Multi-DRM Document](https://doverunner.com/docs/content-security/multi-drm/)


---



# DoveRunnerFairPlay SDK Ojbective-C Sample

### 심플한 DoveRunnerFairPlay SDK 사용 설명

DoveRunner FairPlay Streaming(FPS) Simple 은 `DoveRunnerFairPlay` 프레임워크를 어떻게 사용하는지 `Objective-C`로 심플하게 구현된 프로젝트입니다.



## Using the Sample

- `DoveRunnerFairPlay` SDK 를 사용하는 샘플은 실제 디바이스에서 실행되며 시뮬레이터에서 작동하지 않습니다.
- viewDidLoad() 에서 `DoveRunnerFairPlay` 를 초기화하고 viewDidAppear()에서 라이선스 정보를 설정하고 `AVFoundation` 통해 재생합니다.
- `DoveRunnerFairPlay`에 다양한 API 사용을 확인하려면 `Advanced Sample`를 확인하시기 바랍니다.  



### Adding `DoveRunnerFairPlay.xcframework` to the Sample

- Xcode 프로젝트 타겟에 `General` -> `Embedded Binaries`에 `DoveRunnerFairPlay.xcframework`을 추가합니다.
- 추가한 `DoveRunnerFairPlay.xcframework` 경로를 `Build Settings` -> `Search Paths` -> `Framework Search Paths`에 입력합니다.
- SDK 헤더를 `import` 합니다.

    ~~~objectivec
    	#import <DoveRunnerFairPlay/DoveRunnerFairPlay-ObjC.h>
    ~~~



### Adding Streams to the Sample

- 만약 테스트 할 HLS 스트림이 있다면 Xcode 프로젝트에 `ViewController.m` 파일에 콘텐츠 정보(HLS 스트림)와 서비스 연동 정보를 입력하면 됩니다.

	~~~objectivec
   // Service Integration Information
   #define CERTIFICATE_URL     @""
   #define CONTENT_ID          @""
   #define LICENSE_AUTHDATA    @""
   #define CONTENT_URL         @""
	~~~

- DoveRunner Server 에 Apple 인증서를 등록한 경우, `CERTIFICATE_URL` 값은 [DoveRunner Guide](https://doverunner.com/docs/content-security/multi-drm/clients/fairplay-ios/)  를 참고하여 사용하시기 바랍니다.

### Application Transport Security

- HLS 스트리밍이 스트리밍되지 않는다면 Application Transport Security (ATS) 예외를 Info.plist에 추가해야 합니다. ATS 와 plist 키에 대한 설명은 다음 문서에서 확인 할 수 있습니다.  
- Information Property List Key Reference - NSAppTransportSecurity: <https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33>



### Bitcode

-  **`iOS`** 라이브러리는  `Bitcode` 를 지원하지 않습니다..
   - Xcode 프로젝트 타겟에서 `Build Settings` -> `Build Options` -> `Enable Bitcode`-> `NO`.
-  **`tvOS`** 라이브러리는  `Bitcode` 를 지원합니다.



## Main Files

__ViewController.m__: 

- `DoveRunnerFairPlay` 프레임워크를 활용하여 HLS 스트림을 어떻게 재생하는 메인 파일입니다. 
- `서비스 연동 정보`와 `콘텐츠 정보(HLS)`를 입력하면 재생이 가능합니다.



## 멀티 DRM 서비스

멀티 DRM 서비스 설명과 문의 사항은 아래 주소로 제공됩니다.
- [Homepage](https://www.doverunner.com)
- [Multi-DRM Document](https://doverunner.com/docs/content-security/multi-drm/)



Copyright (C) 2025 DoveRunner. All rights reserved.
