//
//  Copyright © 2017년 INKA ENTWORKS INC. All rights reserved.
//
//  PallyCon Team (http://www.pallycon.com)
//
//  MARK: This class is sample using PallyConFPSSDK.
//  A FPSDownloaderDelegate class leverages PallyConFPSSDK to download FPS content.
//

import Foundation
import AVFoundation
import PallyConFPSSDK

@available(iOS 11.2, *)
public class FPSDownloaderDelegate: NSObject {
    
    fileprivate var downloadTask: DownloadTask?
    
    init(url: URL, contentId: String, token: String) {
        super.init()

        let videoAsset = AVURLAsset(url: url)
        let config = PallyConDrmConfiguration(avURLAsset: videoAsset,
                                              contentId: contentId,
                                              certificateUrl: CERTIFICATE_URL,
                                              authData: token,
                                              delegate: PallyConSDKManager.sharedManager)
        downloadTask = PallyConSDKManager.sharedManager.pallyConFPSSDK?.createDownloadTask(Content: config, delegate: self)
    }
    
    init(url: URL, contentId: String, token: String, minimumBitrate: String ) {
        super.init()
        let videoAsset = AVURLAsset(url: url)
        let config = PallyConDrmConfiguration(avURLAsset: videoAsset,
                                              contentId: contentId,
                                              certificateUrl: CERTIFICATE_URL,
                                              authData: token,
                                              delegate: PallyConSDKManager.sharedManager)
        downloadTask = PallyConSDKManager.sharedManager.pallyConFPSSDK?.createDownloadTask(Content: config, delegate: self, downloadMinimumBitrate: minimumBitrate)
    }
    
    public func startDownload() {
        self.downloadTask?.resume()
    }
    
    public func cancelDownload() {
        self.downloadTask?.cancel()
    }
}

//MARK:- FPSDownloadDelegate protocol methods extension
@available(iOS 11.2, *)
extension FPSDownloaderDelegate: PallyConFPSDownloadDelegate {
    public func downloadContent(_ contentId: String, didStartDownloadWithAsset asset: AVURLAsset, subtitleDisplayName: String) {
        print("didStartDownloadWithAsset contentId = \(contentId), displayName = \(subtitleDisplayName)")
        let userInfo: [String: Any] = [FPSContent.Keys.cId: contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.downloading.rawValue,
                                       FPSContent.Keys.avUrlAsset: asset]
        NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo: userInfo)
    }
    
    public func downloadContent(_ contentId: String, didStopWithError error:Error?) {
        print("didStopWithError contentId = \(contentId)")
       
        let userInfo: [String: Any] = [FPSContent.Keys.cId: contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.pause.rawValue]
        
        if let error = error as? PallyConError {
            var message:String?
            switch error {
            case .download(errorCode: let errorCode, comment: let comment):
                print("code : \(errorCode), comment: \(comment)")
                break
            case .unknown(errorCode: let errorCode, comment: let comment):
                message = "Unknown Error: \(errorCode)\nComment: \(comment)"
                break
            case .failed(errorCode: let errorCode, comment: let comment):
                message = "Failed Error: \(errorCode)\nComment: \(comment)"
                break
            default:
                message = "Error: \(error.localizedDescription)"
                break
            }
            
            let alert = UIAlertController(title: "Download Failed", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo: userInfo)
    }
    
    public func downloadContent(_ contentId: String, didFinishDownloadingTo location: URL)  {
        print("didFinishDownloadingTo contentId = \(contentId)")
        let userDefaults = UserDefaults.standard
        var userInfo: [String: Any] = [FPSContent.Keys.cId:contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.downloaded.rawValue]
        userDefaults.set(location.relativePath, forKey: contentId)
        
        let contentUrl =  PallyConSDKManager.baseDownloadURL.appendingPathComponent(location.relativePath)
        userInfo[FPSContent.Keys.avUrlAsset] = AVURLAsset(url: contentUrl)
        
        NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo: userInfo)
    }
    
    public func downloadContent(_ contentId: String, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange : CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        let userInfo: [String: Any] = [FPSContent.Keys.percentDownloaded: percentComplete, FPSContent.Keys.cId: contentId]
        
        NotificationCenter.default.post(name: FPSDownloadProgressNotification, object: nil, userInfo: userInfo)
    }
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
