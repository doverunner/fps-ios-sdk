# DoveRunnerFairPlay SDK Advanced Sample 

## Overview

This sample app serves as a guide for using the `DoveRunnerFairPlay` SDK. It is an example project that implements key user scenarios, focusing on streaming and offline playback for content protected by Apple FairPlay Streaming (FPS) DRM. This will help you understand the basic user experience flow.


## Key Features

- Tap a `UITableViewCell` to play the corresponding HLS stream.
- Manage HLS streams using the accessory button on each `UITableViewCell`:
	- Start a `DownloadTask`.
	- Cancel an ongoing `DownloadTask`.
	- Delete a downloaded HLS stream.
- When the device is offline, playback is only possible if the HLS stream and its license have been downloaded.
- This sample must be run on a physical device. The SDK's APIs do not work in the iOS Simulator.


## Setup Instructions

Before using the main features of this sample, please verify the following setup steps.

### Adding `GoogleCast.framework`

- The Advanced Sample requires [`GoogleCast.framework`][1]
- Use [CocoaPods][2] to install the framework(`pod install`), then open the generated `FairPlayAdvanced.xcworkspace` file.



### Adding `DoveRunnerFairPlay.xcframework` 

- This sample project already references `../../lib/DoveRunnerFairPlay.xcframework`, which is the location of the SDK in the distribution package (`lib/` and `sample/` side by side). Keep the folder layout and the SDK is linked automatically.
- If you move the sample to another location, add `DoveRunnerFairPlay.xcframework` to the Xcode project target in `General` -> `Frameworks, Libraries, and Embedded Content` (Embed & Sign).
- Import the SDK module where needed (see `SDKManager.swift`).


### Application Transport Security

- If any of the streams you add are not hosted securely, you will need to add an Application Transport Security(ATS) exception in the Info.plist. 
- More information on ATS and the relevant plist keys can be found in the following article:
- Information Property List Key Reference - [NSAppTransportSecurity][3]

### Bitcode

-  **`iOS`** library does **not support** `Bitcode`.
   - In the Xcode project target `Build Settings` -> `Build Options` -> `Enable Bitcode` to `NO`.
-  **`tvOS`** library **supports** `Bitcode`.


### Add FairPlay HLS Streams for Playback

- If you wish to add your own HLS streams to test with using this sample, you can do this by adding an entry into the `Contents.plist` that is part of the Xcode Project.
- There are two important keys you need to provide values for:

	~~~
	OnlyStreaming	: Set to YES if the HLS stream is for streaming only and not downloadable (persistent).
	FPSCidKey	: The content ID for the HLS stream.
	ContentNameKey	: The name of the HLS stream.
	ContentURL	: The URL of the HLS stream.
	FPSToken	: The Auth Data value for the HLS stream.
	~~~
	
- Enter the Service Integration Information in the`SDKManager.swift`file.

	~~~swift
		let drmConfig = FairPlayConfiguration(
                        avURLAsset: AVURLAsset,
                         contentId: Content ID,
                    certificateUrl: Certificate URL,
                          authData: Auth Data)

		DoveRunnerFairPlay.prepare(drm: drmConfig)
	~~~


## Important Notes

- This sample app does not implement all features of the `DoveRunnerFairPlay.xcframework` and may not handle all possible application states.


## Main Files

__SDKManager.swift__: 

- SDKManager is the main class in this sample that demonstrates how to manage downloading HLS streams.  
- It includes APIs for starting and canceling downloads, deleting existing assets off the users device, and monitoring the download progress.

__FPSPlaybackKManager.swift__: 

- FPSPlaybackKManager is the class that manages the playback of Assets in this sample using Key-value observing on various AVFoundation classes.

__FPSListManager.swift__: 

- The FPSListManager class manages loading reading the contents of the Contents.plist file in the application bundle.



## DoveRunner Multi-DRM Service

DoveRunner Multi-DRM Service description and inquiries are available at the address below.
- [DoveRunner][4]
- [DoveRunner Multi-DRM Document][5]


---



# DoveRunnerFairPlay SDK Advanced Sample 

## 개요

해당 샘플은 `DoveRunnerFairPlay` SDK 활용 가이드를 목적으로, 주요 사용자 시나리오를 구현한 예제입니다. Apple FairPlay Streaming(FPS) DRM으로 보호되는 콘텐츠의 스트리밍 및 오프라인 재생 기능 구현에 중점을 두었으며, 이를 통해 기본적인 사용자 경험 흐름을 이해할 수 있습니다.



## 주요 기능

- `UITableViewCell`을 탭하여 해당 HLS 스트림을 재생할 수 있습니다.
- `UITableViewCell`의 액세서리 버튼으로 HLS 스트림을 관리할 수 있습니다.
	- `DownloadTask` 시작
	- 진행 중인 `DownloadTask` 취소
	- 다운로드된 HLS 스트림 삭제
- 디바이스가 오프라인 상태일 때는, HLS 스트림과 라이선스가 모두 다운로드된 경우에만 재생이 가능합니다.
- 이 샘플은 실제 디바이스에서 실행해야 합니다. SDK API는 iOS 시뮬레이터에서 동작하지 않습니다.


## 체크 사항
이 샘플에서 주요 기능을 사용하기 위해 아래 사항이 준비되어 있는지 확인합니다.

### `GoogleCast.framework` 추가

- Sample -> Advanced 샘플은 [`GoogleCast.framework`](https://developers.google.com/cast/docs/developers#ios)가 필요합니다.
- [`COCOAPODS`](https://cocoapods.org/)을 이용하여 `GoogleCast.framework`을 설치(`pod install`)하고 생성된 `FairPlayAdvanced.xcworkspace` 를 실행합니다. 



### `DoveRunnerFairPlay.xcframework` 추가

- 이 샘플 프로젝트는 배포 패키지의 SDK 위치인 `../../lib/DoveRunnerFairPlay.xcframework`를 이미 참조하고 있습니다(`lib/`와 `sample/`가 나란히 있는 구조). 폴더 구조를 유지하면 SDK가 자동으로 링크됩니다.
- 샘플을 다른 위치로 옮긴 경우에는 Xcode 프로젝트 타겟의 `General` -> `Frameworks, Libraries, and Embedded Content`에 `DoveRunnerFairPlay.xcframework`를 추가(Embed & Sign)합니다.
- 필요한 곳에서 SDK 모듈을 `import` 합니다(`SDKManager.swift` 참고).

	~~~swift
		import DoveRunnerFairPlay
	~~~

### Application Transport Security

- HLS 스트리밍이 스트리밍되지 않는다면 Application Transport Security (ATS) 예외를 Info.plist에 추가해야 합니다. ATS 와 plist 키에 대한 설명은 다음 문서에서 확인 할 수 있습니다.  
- Information Property List Key Reference - NSAppTransportSecurity: <https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33>



### Bitcode

-  **`iOS`** 라이브러리는  `Bitcode` 를 지원하지 않습니다..
   - Xcode 프로젝트 타겟에서 `Build Settings` -> `Build Options` -> `Enable Bitcode`-> `NO`.
-  **`tvOS`** 라이브러리는  `Bitcode` 를 지원합니다.


### 재생 할 FairPlay HLS 스트림 추가

- 샘플에 테스트할 FairPlay로 패키징된 HLS 스트림을 추가하려면, Xcode 프로젝트에 `Shared` -> `Resources` -> `Contents.plist` 에 추가합니다.

	~~~swift
		OnlyStreaming	: HLS 스트림이 다운로드 가능한(persistent) 콘텐츠가 아니라면 YES 입니다.
		FPSCidKey	: HLS 스트림의 콘텐츠 ID입니다. token 값이 없을 경우 입력해야 합니다.
		ContentNameKey	: HLS 스트림의 이름입니다. 앱 리스트에 표시됩니다.
		ContentURL	: HLS 스트림 URL 입니다.
		FPSToken	: HLS 스트림의 token 값 입니다.
	~~~
	
- `SDKManager.swift` 파일에 서비스 연동 정보를 입력하면 됩니다.

	~~~swift
		
		let drmConfig = FairPlayConfiguration(
								avURLAsset: AVURLAsset,
                                 contentId: Content ID,
                            certificateUrl: Certificate URL,
                                  authData: Auth Data)

		DoveRunnerFairPlay.prepare(drm: drmConfig)
	~~~




## Important Notes

- 이 샘플이  `DoveRunnerFairPlay.xcframework` 의 모든 기능을 구현되어 있지 않으며, 모든 앱 상태에 대응하지 않습니다.



## Main Files

__SDKManager.swift__: 

-  `DoveRunnerFairPlay.xcframework` 를 이용하여 초기화, 라이선스 획득, 다운로드를 어떻게 하는지 보여주는 메인 클래스입니다.
- HLS 스트림 다운로드와 운영 방법을 알수 있습니다. 

__FPSPlaybackKManager.swift__: 

- HLS 스트림의 재생을 구현한 클래스입니다. 재생 시 라이선스 획득 시점을 알수 있습니다.

__FPSListManager.swift__: 

- `Contents.plist`의 내용을 읽고 로드하는 클래스입니다.




## DoveRunner 멀티 DRM 서비스

DoveRunner 멀티 DRM 서비스 설명과 문의 사항은 아래 주소로 제공됩니다.
- [DoveRunner][4]
- [DoveRunner Multi-DRM Document][5]



Copyright (C) 2019 DoveRunner. All rights reserved.


[1]: https://developers.google.com/cast/docs/developers#ios
[2]: https://cocoapods.org/
[3]: https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33
[4]: https://www.doverunner.com
[5]: https://docs.doverunner.com