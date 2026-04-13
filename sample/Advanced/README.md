# DoveRunner FairPlay Advanced Sample

### HLS Stream download and Playback

This sample demonstrates how to use the `DoveRunnerFairPlay` framework to play HTTP Live Streams hosted on remote servers as well as how to persist the HLS streams on disk for offline playback.



## Using the Sample

- Build and run the sample on an actual device using Xcode. The APIs demonstrated in this sample do not work on the iOS Simulator.
- This sample provides a list of HLS Streams that you can playback by tapping on the `UITableViewCell` corresponding to the stream.
- If you wish to manage the download of an HLS stream such as initiating an `DownloadTask`, canceling an already running `DownloadTask` or deleting an already downloaded HLS stream from disk, you can accomplish this by tapping on the accessory button on the `UITableViewCell` corresponding to the stream you wish to manage.



### Adding `GoogleCast.framework` to the Sample

- Advanced Sample requires [`GoogleCast.framework`](https://developers.google.com/cast/docs/developers#ios).
- Install(`pod install`) the `GoogleCast.framework` using [`COCOAPODS`](https://cocoapods.org/) and run the generated `FairPlayAdvanced.xcworkspace`.



### Adding `DoveRunnerFairPlay.xcframework` to the Sample

- Add `DoveRunnerFairPlay.xcframework` to Xcode project target in `General` -> `Frameworks, Libraries, and Embedded Content`.
- Add `DoveRunnerFairPlay.xcframework` to the `Build Settings` -> `Search Paths` -> `Framework Search Paths` path.
- Import the SDK header (`SDKManager.swift`).

	~~~
		import DoveRunnerFairPlay
	~~~



### Adding Streams to the Sample

- If you wish to add your own HLS streams to test with using this sample, you can do this by adding an entry into the `Contents.plist` that is part of the Xcode Project.
- There are two important keys you need to provide values for:

	~~~
		OnlyStreaming	: If the HLS stream is not downloadable(persistent) content, OnlyStreaming is YES.
		FPSCidKey	: Content ID of the HLS stream. If there is no token value, you must enter it.
		ContentNameKey	: What the display name of the HLS stream should be in the sample.
		ContentURL	: The URL of the HLS stream's master playlist.
		FPSToken	: HLS stream's token.
	~~~

- Enter the Service Integration Information in the `SDKManager.swift` file.

	~~~swift
		// Service Integration Information
		let drmConfig = FairPlayConfiguration()
	~~~



### Application Transport Security

- If any of the streams you add are not hosted securely, you will need to add an Application Transport Security(ATS) exception in the Info.plist.
- More information on ATS and the relevant plist keys can be found in the following article:
- NSAppTransportSecurity: <https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity>



## Important Notes

- This sample does not implement all the features of `DoveRunnerFairPlay.xcframework` and does not correspond to all app states.



## Main Files

__SDKManager.swift__:

- SDKManager is the main class in this sample that demonstrates how to manage downloading HLS streams.
- It includes APIs for starting and canceling downloads, deleting existing assets off the users device, and monitoring the download progress.

__FPSPlaybackKManager.swift__:

- FPSPlaybackKManager is the class that manages the playback of Assets in this sample using Key-value observing on various AVFoundation classes.

__FPSListManager.swift__:

- The FPSListManager class manages loading and reading the contents of the Contents.plist file in the application bundle.



## DoveRunner Multi-DRM Service

DoveRunner Multi-DRM Service description and inquiries are available at the address below.
- [DoveRunner Homepage](https://www.doverunner.com)
- [DoveRunner Multi-DRM Document](https://doverunner.com/docs/)


---



# DoveRunner FairPlay Advanced Sample

### HLS 스트림 다운로드와 DoveRunnerFairPlay SDK 사용 설명

DoveRunner FairPlay Streaming(FPS) Advanced 는 `DoveRunnerFairPlay` 프레임워크를 어떻게 사용하는지 `Swift`로 구현된 프로젝트입니다.



## 샘플 사용 방법

- 샘플은 Xcode에서 실제 디바이스에서 빌드되어 실행됩니다. 이 샘플에서 설명된 API는 iOS 시뮬레이터에서 작동하지 않습니다.
- 이 샘플은 스트림에 해당하는 `UITableViewCell`을 탭하여 재생할 수 있는 HLS 스트림 목록을 제공합니다.
- `DownloadTask`를 시작하거나, 이미 실행중인 `DownloadTask`를 취소하거나, 디스크에서 이미 다운로드한 HLS 스트림을 삭제하는 등의 관리를 하려면, 해당 스트림의 `UITableViewCell` 액세서리 버튼을 탭하여 수행할 수 있습니다.



### 샘플에 `GoogleCast.framework` 추가

- Advanced 샘플은 [`GoogleCast.framework`](https://developers.google.com/cast/docs/developers#ios)가 필요합니다.
- [`COCOAPODS`](https://cocoapods.org/)을 이용하여 `GoogleCast.framework`을 설치(`pod install`)하고 생성된 `FairPlayAdvanced.xcworkspace`를 실행합니다.



### 샘플에 `DoveRunnerFairPlay.xcframework` 추가

- Xcode 프로젝트 타겟의 `General` -> `Frameworks, Libraries, and Embedded Content`에 `DoveRunnerFairPlay.xcframework`를 추가합니다.
- 추가한 `DoveRunnerFairPlay.xcframework` 경로를 `Build Settings` -> `Search Paths` -> `Framework Search Paths`에 입력합니다.
- SDK 헤더를 `import` 합니다(`SDKManager.swift`).

	~~~
		import DoveRunnerFairPlay
	~~~



### 샘플에 스트림 추가

- 샘플에서 테스트할 HLS 스트림을 추가하려면, Xcode 프로젝트의 `Shared` -> `Resources` -> `Contents.plist`에 항목을 추가합니다.

	~~~
		OnlyStreaming	: HLS 스트림이 다운로드 가능한(persistent) 콘텐츠가 아니라면 YES 입니다.
		FPSCidKey	: HLS 스트림의 콘텐츠 ID입니다. token 값이 없을 경우 입력해야 합니다.
		ContentNameKey	: HLS 스트림의 이름입니다. 앱 리스트에 표시됩니다.
		ContentURL	: HLS 스트림 URL 입니다.
		FPSToken	: HLS 스트림의 token 값 입니다.
	~~~

- `SDKManager.swift` 파일에 서비스 연동 정보를 입력합니다.

	~~~swift
		// 서비스 연동 정보
		let drmConfig = FairPlayConfiguration()
	~~~



### Application Transport Security

- 보안(HTTPS)이 적용되지 않은 HTTP 스트림을 사용하는 경우, Info.plist에 Application Transport Security(ATS) 예외를 추가해야 합니다.
- ATS 및 관련 plist 키에 대한 자세한 내용은 다음 문서를 참고하세요.
- NSAppTransportSecurity: <https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity>



## 주의 사항

- 이 샘플은 `DoveRunnerFairPlay.xcframework`의 모든 기능을 구현하고 있지 않으며, 모든 앱 상태에 대응하지 않습니다.



## 주요 파일

__SDKManager.swift__:

- `DoveRunnerFairPlay.xcframework`를 이용하여 초기화, 라이선스 획득, 다운로드를 어떻게 하는지 보여주는 메인 클래스입니다.
- HLS 스트림 다운로드와 운영 방법을 확인할 수 있습니다.

__FPSPlaybackKManager.swift__:

- HLS 스트림의 재생을 구현한 클래스입니다. 재생 시 라이선스 획득 시점을 확인할 수 있습니다.

__FPSListManager.swift__:

- `Contents.plist`의 내용을 읽고 로드하는 클래스입니다.



## DoveRunner 멀티 DRM 서비스

DoveRunner 멀티 DRM 서비스 설명과 문의 사항은 아래 주소로 제공됩니다.
- [DoveRunner Homepage](https://www.doverunner.com)
- [DoveRunner Multi-DRM Document](https://doverunner.com/docs/)



Copyright (C) 2026 DoveRunner. All rights reserved.
