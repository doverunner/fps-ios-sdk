//
//  Copyright © 2017년 DoveRunner INC. All rights reserved.
//
//  DoveRunner DRM Team (http://www.doverunner.com)
//
//  MARK: This class is sample using DoveRunnerFairPlay.
//  A SDKManager class decribes the overall usage of DoveRunnerFairPlay.
//


import Foundation
import AVFoundation
import UIKit
#if os(iOS)
     import DoveRunnerFairPlay
#else
     import DoveRunnerFairPlayTV
#endif


// MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD.
// This is customer-specific information.
// you have to set customer information.
// Shared -> Resources -> Contents.plist, enter content information.

let CERTIFICATE_URL = "https://drm-license.doverunner.com/ri/fpsKeyManager.do?siteId=XXXX"

let FPSDownloadProgressNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSDownloadProgressNotification")
let FPSDownloadStateChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSDownloadStateChangedNotification")
let FPSAcquireLicenseSuccessNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSAcquireLicenseSuccessNotification")
let FPSAcquireLicenseFailNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSAcquireLicenseFailNotification")

class SDKManager: NSObject {
     static let sharedManager = SDKManager()
     
     // DoveRunnerFairPlay initalize
     lazy var doverunnerSdk: DoveRunnerFairPlay? = {
          return DoveRunnerFairPlay()
     }()
     
     static let baseDownloadURL: URL = URL(fileURLWithPath: NSHomeDirectory())
     
     fileprivate var activeDownloadsMap = [String : FPSContent]()
     fileprivate var downloadStatusMap = [String : String]()
     
     // Get fps content infomation on local
     @available(iOS 10.0, *)
     func localFpsContentForStream(with contentId: String, token: String, contentName: String ) -> FPSContent? {
          let userDefaults = UserDefaults.standard
          guard let localFileLocation = userDefaults.value(forKey: contentId) as? String else { return nil }
          
          let url = SDKManager.baseDownloadURL.appendingPathComponent(localFileLocation)
          let urlAsset = AVURLAsset(url: url)
          
          let fpsContent = FPSContent(contentId, token, contentName, urlAsset)
          
          return fpsContent
     }
     
     #if os(iOS)
     // download start
     @available(iOS 11.2, *)
     func downloadStream(for fpsContent: FPSContent, minimumBitrate: String = String()) {
          var content: FPSContent? = activeDownloadsMap[fpsContent.contentId]
          if content == nil {
               content = fpsContent
               if minimumBitrate != String() {
                    content!.downloadDelegate = FPSDownloaderDelegate(url: fpsContent.urlAsset.url, contentId: fpsContent.contentId, token: fpsContent.token, licenseUrl: fpsContent.licenseUrl, minimumBitrate: minimumBitrate)
               } else {
                    content!.downloadDelegate = FPSDownloaderDelegate(url: fpsContent.urlAsset.url, contentId: fpsContent.contentId, token: fpsContent.token, licenseUrl: fpsContent.licenseUrl)
               }
                activeDownloadsMap[content!.contentId] = content
          }
          downloadStatusMap[content!.contentId] = FPSContent.DownloadState.downloading.rawValue
          
          let userInfo = [FPSContent.Keys.cId: fpsContent.contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.downloading.rawValue]
          NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
          
          let task: FPSDownloaderDelegate = content!.downloadDelegate as! FPSDownloaderDelegate
          task.startDownload()
     }
     
     // pause download
     @available(iOS 11.2, *)
     func pauseDownload(for fpsContent: FPSContent) {
          var task: FPSDownloaderDelegate?
          
          for (key, contentValue) in activeDownloadsMap {
               if contentValue.contentId == fpsContent.contentId {
                    task = contentValue.downloadDelegate as! FPSDownloaderDelegate?
                    downloadStatusMap[key] = FPSContent.DownloadState.pause.rawValue
                    break
               }
          }
          
          task?.cancelDownload()
          
          let userInfo = [FPSContent.Keys.cId: fpsContent.contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.pause.rawValue]
          NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
     }
     
     // cancel download
     @available(iOS 11.2, *)
     func cancelDownload(for fpsContent: FPSContent) {
          var task: FPSDownloaderDelegate?
          
          for (key, contentValue) in activeDownloadsMap {
               if contentValue.contentId == fpsContent.contentId {
                    task = contentValue.downloadDelegate as! FPSDownloaderDelegate?
                    downloadStatusMap[key] = FPSContent.DownloadState.notDownloaded.rawValue
                    break
               }
          }
          
          task?.cancelDownload()
          
          var userInfo: [String:Any] = [FPSContent.Keys.cId: fpsContent.contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.notDownloaded.rawValue]
          if let originalAsset = FPSListManager.sharedManager.getContentUrlAsset(contentId: fpsContent.contentId) {
               userInfo[FPSContent.Keys.avUrlAsset] = AVURLAsset(url: originalAsset.url)
          }
          
          NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
     }
     
     // Get current download status
     @available(iOS 11.0, *)
     func downloadState(for fpsContent: FPSContent) -> FPSContent.DownloadState {
          let userDefaults = UserDefaults.standard
          
          if let localFileLocation = userDefaults.value(forKey: fpsContent.contentId) as? String {
               let localFilePath = SDKManager.baseDownloadURL.appendingPathComponent(localFileLocation).path
               
               if localFilePath == SDKManager.baseDownloadURL.path {
                    return .notDownloaded
               }
               
               if FileManager.default.fileExists(atPath: localFilePath) {
                    return .downloaded
               }
          }
          
          for (key, contentValue) in activeDownloadsMap {
               if contentValue.contentId == fpsContent.contentId {
                    if downloadStatusMap[key] == FPSContent.DownloadState.pause.rawValue {
                         return .pause
                    } else if (downloadStatusMap[key] == FPSContent.DownloadState.notDownloaded.rawValue) {
                         return .notDownloaded
                    }
                    
                    return .downloading
               }
          }
          
          return .notDownloaded
     }
     
     // content delete
     @available(iOS 11.0, *)
     func deleteFPSContent(for fpsContent: FPSContent) {
          let userDefaults = UserDefaults.standard
          
          do {
               if let localFileLocation = userDefaults.value(forKey: fpsContent.contentId) as? String {
                    let localFileLocation = SDKManager.baseDownloadURL.appendingPathComponent(localFileLocation)
                    try FileManager.default.removeItem(at: localFileLocation)
                    
                    userDefaults.removeObject(forKey: fpsContent.contentId)
                    try self.doverunnerSdk?.removeLicense(contentId: fpsContent.contentId)
                    activeDownloadsMap.removeValue(forKey: fpsContent.contentId)
                    
                    var userInfo: [String:Any] = [FPSContent.Keys.cId: fpsContent.contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.notDownloaded.rawValue]
                    if let originalAsset = FPSListManager.sharedManager.getContentUrlAsset(contentId: fpsContent.contentId) {
                         userInfo[FPSContent.Keys.avUrlAsset] = originalAsset
                    }
                    
                    NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
               }
          } catch {
               print("An error occured deleting the file: \(error)")
          }
     }
     
     // download pause
     @available(iOS 11.0, *)
     func pauseDownloadStatus(for contentId: String) {
          for (key, contentValue) in activeDownloadsMap {
               if contentValue.contentId == contentId {
                    downloadStatusMap[key] = FPSContent.DownloadState.pause.rawValue
                    break
               }
          }
     }
     #endif
}

/**
 Extend `SDKManager` to conform to the `FairPlayLicenseDelegate` protocol.
 Get a error acquiring license
 */
extension SDKManager: FairPlayLicenseDelegate {
     
     func license(result: LicenseResult) {
          print("---------------------------- License Result ")
          print("Content ID : \(result.contentId)")
          print("Key ID     : \(String(describing: result.keyId))")

          var message: String?
          if result.isSuccess == false {
               print("Error : \(String(describing: result.error?.localizedDescription))")
               if let error = result.error {
                    switch error {
                    case .database(comment: let comment):
                         print(comment)
                         message = comment
                    case .server(errorCode: let errorCode, comment: let comment):
                         print("code : \(errorCode), comment: \(comment)")
                         message = "code : \(errorCode), comment: \(comment)"
                    case .network(errorCode: let errorCode, comment: let comment):
                         print("code : \(errorCode), comment: \(comment)")
                         message = "code : \(errorCode), comment: \(comment)"
                    case .system(errorCode: let errorCode, comment: let comment):
                         print("code : \(errorCode), comment: \(comment)")
                         message = "code : \(errorCode), comment: \(comment)"
                    case .failed(errorCode: let errorCode, comment: let comment):
                         print("code : \(errorCode), comment: \(comment)")
                         message = "code : \(errorCode), comment: \(comment)"
                    case .unknown(errorCode: let errorCode, comment: let comment):
                         print("code : \(errorCode), comment: \(comment)")
                         message = "code : \(errorCode), comment: \(comment)"
                    case .invalid(comment: let comment):
                         print("comment: \(comment)")
                         message = "comment: \(comment)"
                    default:
                         print("comment: \(error)")
                         message = "comment: \(error)"
                        break
                    }
               }
               DispatchQueue.main.async {
                    if let topVC = UIApplication.topViewController() {
                         let alert = UIAlertController(title: "License Failed", message: message, preferredStyle: .alert)
                         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { Void in
                              topVC.dismiss(animated: true, completion: nil)
                         }))
                         topVC.present(alert, animated: true, completion: nil)
                    }
               }
          }
     }
     
     
     func addCMCDDataToRequest(url: URL) -> URLRequest {
         var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
         var request = URLRequest(url: url)
          //request.addValue("AuthData-token=Send-HeaderField-Send-HeaderField-Send-HeaderField", forHTTPHeaderField: "CMCD-Object")
          request.addValue("cid=072298a7-ce89-4f44-9ce5-22fde6271fc2", forHTTPHeaderField: "CMCD-Session")
          return request
         
         // CMCD 데이터를 딕셔너리로 준비
         var cmcdData: [String: String] = [:]
          
          let token = "AuthData-Token-AuthData-Token-AuthData-Token-AuthData-Token-AuthData-Token"
          cmcdData["AuthData-token"] = token
     
         // 세션 ID
         let sessionId = UUID().uuidString
         cmcdData["sid"] = "\"\(sessionId)\""
         
         // 비트레이트
         let bitrate = 3200
         cmcdData["br"] = "\(bitrate)"
         
         // 버퍼 고갈 상태
         cmcdData["bs"] = "" // 값이 없는 경우 빈 문자열
         
         // 객체 지속 시간
         let duration = 4004
         cmcdData["d"] = "\(duration)"
         
         // 측정된 처리량
         let measuredThroughput = 25400
         cmcdData["mtp"] = "\(measuredThroughput)"
         
         // 객체 유형
         cmcdData["ot"] = "v"
         
         // 요청된 최대 처리량
         let requestedThroughput = 15000
         cmcdData["rtp"] = "\(requestedThroughput)"
         
         // 최대 비트레이트
         let topBitrate = 6000
         cmcdData["tb"] = "\(topBitrate)"
         
         // CMCD 데이터를 쿼리 문자열로 변환
         let cmcdString = cmcdData.map { key, value in
             if value.isEmpty {
                 return key
             } else {
                 return "\(key)=\(value)"
             }
         }.joined(separator: ",")
         
         // URL 인코딩
         let encodedCMCD = cmcdString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cmcdString
         
         // 기존 쿼리 항목이 있으면 유지하고 CMCD 추가
         var queryItems = components.queryItems ?? []
         queryItems.append(URLQueryItem(name: "CMCD", value: encodedCMCD))
         components.queryItems = queryItems
         
         // 수정된 URL을 request에 설정
         request.url = components.url
         
         // HTTP 헤더에 CMCD 데이터 추가
         request.addValue("sid=\"\(sessionId)\"", forHTTPHeaderField: "CMCD-Session")
         request.addValue("mtp=\(measuredThroughput)", forHTTPHeaderField: "CMCD-Request")
         request.addValue("br=\(bitrate),d=\(duration),ot=v,tb=\(topBitrate),token=\(token)", forHTTPHeaderField: "CMCD-Object")
         
         var statusValues = ["bs"]
         statusValues.append("rtp=\(requestedThroughput)")
         request.addValue(statusValues.joined(separator: ","), forHTTPHeaderField: "CMCD-Status")
         
         return request
     }
     
     func replaceURLWithScheme(_ scheme: String, _ url: URL) -> URL? {
         let urlString = url.absoluteString
         guard let index = urlString.firstIndex(of: ":") else { return nil }
         let rest = urlString[index...]
         let newUrlString = scheme + rest
         return URL(string: newUrlString)
     }
     
     func resourceLoaderCallback(requestResource: AVAssetResourceLoadingRequest) -> Bool {
          // This is an example for applying `DoveRunnerFairPlay.mainm3u8Scheme` and testing the playback.
          guard let originalUrl = requestResource.request.url?.absoluteString else { return false }
          
          guard let changeUrl = replaceURLWithScheme("https", URL(string: originalUrl)! ) else {
               let error = SDKError.invalid(comment: "replace URL scheme error")
               requestResource.finishLoading(with: error)
               return false
          }

          print("---------> originalUrl : \(originalUrl)")
          print("---------> changeUrl   : \(changeUrl)")
          var playback_session_id : String?
          if let headers = requestResource.request.allHTTPHeaderFields {
              print("HTTP Headers: ------------------------- ")
              for (key, value) in headers {
                  print("\(key): \(value)")
                   
                   if "X-Playback-Session-Id" == key as String {
                        playback_session_id = value
                   }
              }
          }
          print("HTTP Headers: ------------------------- ")
          
          if originalUrl.hasSuffix("m3u8") == false {
               
//               var requestWithCMCD = addCMCDDataToRequest(url: changeUrl)
//               requestWithCMCD.addValue(playback_session_id!, forHTTPHeaderField: "x-playback-session-id")
//               print(requestWithCMCD.url?.absoluteString ?? "URL is nil")
//               
//               if let redirectURL = requestWithCMCD.url {
//                   print("---------> requestResource.request.url : \(requestResource.request.url?.absoluteString ?? "nil")")
//                   print("---------> redirectURL                 : \(redirectURL)")
//                    
//                    print("---------> requestWithCMCD   : \(requestWithCMCD.url?.absoluteString)")
//                    if let headers = requestWithCMCD.allHTTPHeaderFields {
//                        print("requestWithCMCD Headers: ------------------------- ")
//                        for (key, value) in headers {
//                            print("\(key): \(value)")
//                        }
//                    }
//                    print("requestWithCMCD Headers: ------------------------- ")
//                    
//                   requestResource.redirect = requestWithCMCD
//                   requestResource.response = HTTPURLResponse(url: redirectURL, statusCode: 302, httpVersion: nil, headerFields: nil)
//                   requestResource.finishLoading()
//               }
               if let redirectURL = URL(string: changeUrl.absoluteString, relativeTo: requestResource.request.url) {
                    print("---------> requestResource.request.url : \(requestResource.request.url?.absoluteString)")
                    print("---------> redirectURL                 : \(redirectURL)")
                    requestResource.redirect = URLRequest(url: redirectURL)
                    requestResource.response = HTTPURLResponse(url: redirectURL, statusCode: 302, httpVersion: nil, headerFields: nil)
                    requestResource.finishLoading()
               }
               return true
          }

          guard let dataRequest = requestResource.dataRequest else {
               let error = SDKError.invalid(comment: "loadingRequest.dataRequest error")
               requestResource.finishLoading(with: error)
               return false
          }
          
          let task = URLSession.shared.dataTask(with: changeUrl) { (data, response, error) in
               guard error == nil, let data = data else {
                    requestResource.finishLoading(with: error)
                    return
               }

               guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {return}
               let successRange = 200..<300
               guard successRange.contains(statusCode) else {
                    // handle response error
                    print("http status code \(statusCode)")
                    return
               }
               
               guard let string = String(data: data, encoding: .utf8) else { return }
               dataRequest.respond(with: string.data(using: .utf8)!)
               requestResource.finishLoading()

          }
          task.resume()
          
          return true
     }
     
     /*
     func licenseCallback(with spcData: Data, httpHeader header: [String : String]?) -> Data? {
          guard let url = URL(string: "  ") else {
              return Data()
          }
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          if var unwrappedHeader = header {
               if unwrappedHeader.keys.contains("pallycon-customdata-v2") {
                    //unwrappedHeader.removeValue(forKey: "pallycon-customdata-v2")
                    //unwrappedHeader["pallycon-customdata-v2"] = "new auth data"
                    print("Token : \(String(describing: unwrappedHeader["pallycon-customdata-v2"]))")
               }
               request.allHTTPHeaderFields = unwrappedHeader
          }
          request.httpBody = spcData
                    
          var task: URLSessionDataTask?
          
          let urlConfig = URLSessionConfiguration.default
          urlConfig.timeoutIntervalForRequest = 5
          urlConfig.timeoutIntervalForResource = 5
          let session = URLSession(configuration: urlConfig)
          
          let semaphore = DispatchSemaphore(value: 0)
          var returnData: (data: Data?, response: HTTPURLResponse?, error: Error?) = (nil, nil, nil)
          task = session.dataTask(with: request) {
              (data, response, error) in
              
              guard let httpURLResponse = response as? HTTPURLResponse,
                  error == nil,
                  data != nil
                  else {
                      semaphore.signal()
                      return
              }
              
              returnData = (data, httpURLResponse, error)
              
              semaphore.signal()
          }
          task?.resume()
          _ = semaphore.wait(timeout: .distantFuture)
          
          return returnData.data
     }
      */
}

extension UIApplication {
     class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
          if let navigationController = controller as? UINavigationController {
               return topViewController(controller: navigationController.visibleViewController)
          }
          if let tabController = controller as? UITabBarController {
               if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
               }
          }
          if let presented = controller?.presentedViewController {
               return topViewController(controller: presented)
          }
          return controller
     }
}
