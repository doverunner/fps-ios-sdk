//
//  Copyright © 2017년 INKA ENTWORKS INC. All rights reserved.
//
//  PallyCon Team (http://www.pallycon.com)
//
//  MARK: This class is sample using PallyConFPSSDK.
//  A PallyConSDKManger class decribes the overall usage of PallyConFPSSDK.
//


import Foundation
import AVFoundation
import UIKit
#if os(iOS)
     import PallyConFPSSDK
#else
     import PallyConFPSSDKTV
#endif


// MARK: ADAPT: YOU MUST IMPLEMENT THIS METHOD.
// This is customer-specific information.
// you have to set customer information.
// Shared -> Resources -> Contents.plist, enter content information.
let pallyConSiteId = ""
let pallyConSiteKey = ""
let pallyConUserId = ""

let FPSDownloadProgressNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSDownloadProgressNotification")
let FPSDownloadStateChangedNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSDownloadStateChangedNotification")
let FPSAcquireLicenseSuccessNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSAcquireLicenseSuccessNotification")
let FPSAcquireLicenseFailNotification: NSNotification.Name = NSNotification.Name(rawValue: "FPSAcquireLicenseFailNotification")

class PallyConSDKManager: NSObject {
     static let sharedManager = PallyConSDKManager()
     
     // PallyConFPSSDK initalize
     lazy var pallyConFPSSDK: PallyConFPSSDK? = {
          do {
               return try PallyConFPSSDK(siteId: pallyConSiteId, siteKey: pallyConSiteKey, fpsLicenseDelegate: self)
          } catch PallyConSDKException.DatabaseProcessError(let message) {
               print("PallyConFPSSDK initilize failed.\n\(message)")
          } catch {
               print("Error: \(error).\nUnkown Error")
          }
          
          return nil
     }()
     
     static let baseDownloadURL: URL = URL(fileURLWithPath: NSHomeDirectory())
     
     fileprivate var activeDownloadsMap = [String : FPSContent]()
     fileprivate var downloadStatusMap = [String : String]()
     
     // Get fps content infomation on local
     @available(iOS 11.0, *)
     func localFpsContentForStream(with contentId: String, optionalId: String, token: String, contentName: String ) -> FPSContent? {
          let userDefaults = UserDefaults.standard
          guard let localFileLocation = userDefaults.value(forKey: contentId) as? String else { return nil }
          
          let url = PallyConSDKManager.baseDownloadURL.appendingPathComponent(localFileLocation)
          let urlAsset = AVURLAsset(url: url)
          
          let fpsContent = FPSContent(contentId, token, optionalId, contentName, urlAsset)
          
          return fpsContent
     }
     
     #if os(iOS)
     // download start
     @available(iOS 11.0, *)
     func downloadStream(for fpsContent: FPSContent) {
          var content: FPSContent? = activeDownloadsMap[fpsContent.contentId]
          if content == nil {
               content = fpsContent
               content!.downloadDelegate = FPSDownloaderDelegate(url: fpsContent.urlAsset.url, contentId: fpsContent.contentId, optionalId: fpsContent.optionalId, token: fpsContent.token)
               activeDownloadsMap[content!.contentId] = content
          }
          downloadStatusMap[content!.contentId] = FPSContent.DownloadState.downloading.rawValue
          
          let task: FPSDownloaderDelegate = content!.downloadDelegate as! FPSDownloaderDelegate
          task.startDownload()
          
          let userInfo = [FPSContent.Keys.cId: fpsContent.contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.downloading.rawValue]
          NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo:  userInfo)
     }
     
     // pause download
     @available(iOS 11.0, *)
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
     @available(iOS 11.0, *)
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
               let localFilePath = PallyConSDKManager.baseDownloadURL.appendingPathComponent(localFileLocation).path
               
               if localFilePath == PallyConSDKManager.baseDownloadURL.path {
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
                    let localFileLocation = PallyConSDKManager.baseDownloadURL.appendingPathComponent(localFileLocation)
                    try FileManager.default.removeItem(at: localFileLocation)
                    
                    userDefaults.removeObject(forKey: fpsContent.contentId)
                    try self.pallyConFPSSDK?.removeLicense(contentId: fpsContent.contentId)
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
 Extend `PallyConSDKManager` to conform to the `PallyConFPSLicenseDelegate` protocol.
 Get a error acquiring license
 */
extension PallyConSDKManager: PallyConFPSLicenseDelegate {
     func fpsLicenseDidSuccessAcquiring(contentId: String) {
          print("acquireLicense sucesss. contents ID: \(contentId)")
     }
     
     func fpsLicense(contentId: String, didFailWithError error: Error) {
          print("acquireLicense fail. contents ID: \(contentId), License Error: \(error)")
          let userInfo: [String:Any] = [FPSContent.Keys.cId: contentId, FPSContent.Keys.acquireLicenseFail: error]
          NotificationCenter.default.post(name: FPSAcquireLicenseFailNotification, object: nil, userInfo:  userInfo)
     }
     
     func replaceURLWithScheme(_ scheme: String, _ url: URL) -> URL? {
         let urlString = url.absoluteString
         guard let index = urlString.firstIndex(of: ":") else { return nil }
         let rest = urlString[index...]
         let newUrlString = scheme + rest
         return URL(string: newUrlString)
     }
     
     func resourceLoaderRequest(_ requestResource: AVAssetResourceLoadingRequest) -> Bool {
          // This is an example for applying `PallyConFPSSDK.mainm3u8Scheme` and testing the playback.
          guard let originalUrl = requestResource.request.url?.absoluteString else {
               return false
          }
          
          guard let changeUrl = replaceURLWithScheme("https", URL(string: originalUrl)! ) else {
               let error = PallyConSDKException.InvalidParameter("replace URL scheme error")
               requestResource.finishLoading(with: error)
               return false
          }
          
          guard let dataRequest = requestResource.dataRequest else {
               let error = PallyConSDKException.InvalidParameter("loadingRequest.dataRequest error")
               requestResource.finishLoading(with: error)
               return false
          }
          let task = URLSession.shared.dataTask(with: changeUrl) {
                      [weak self] (data, response, error) in
                      guard error == nil,
                          let data = data else {
                              requestResource.finishLoading(with: error)
                              return
                      }
               guard let string = String(data: data, encoding: .utf8) else { return }
               print("download m3u8 : \(string)")
               dataRequest.respond(with: string.data(using: .utf8)!)
               requestResource.finishLoading()
          }
          task.resume()
          
          return true
     }
     
     /*
     func contentKeyRequest(keyData: Data, requestData: [String:String]) -> Data? {
          
          guard let url = URL(string: "https://license.pallycon.com/ri/licenseManager.do") else {
              return Data()
          }
          var request = URLRequest(url: url)
          request.httpMethod = "POST"
          request.allHTTPHeaderFields = requestData
          request.httpBody = keyData
                    
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
     }*/
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
