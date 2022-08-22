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

@available(iOS 11.0, *)
public class FPSDownloaderDelegate: NSObject {
    
    fileprivate var downloadTask: DownloadTask?
    
    init(url: URL, contentId: String, optionalId: String, token: String) {
        super.init()

        if token.count > 0 {
            downloadTask = PallyConSDKManager.sharedManager.pallyConFPSSDK?.createDownloadTask(url: url, userId: pallyConUserId, contentId: contentId, token: token, downloadDelegate: self)
        } else {
            downloadTask = PallyConSDKManager.sharedManager.pallyConFPSSDK?.createDownloadTask(url: url, userId: pallyConUserId, contentId: contentId, optionalId: optionalId, downloadOptions: "", downloadDelegate: self)
        }
    }
    
    public func startDownload() {
        self.downloadTask?.resume()
    }
    
    public func cancelDownload() {
        self.downloadTask?.cancel()
    }
}

//MARK:- FPSDownloadDelegate protocol methods extension
@available(iOS 11.0, *)
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
        
        if let error = error as? PallyConSDKException {
            switch error {
            case .DownloadUserCancel(let filePath):
                print("User Cancel Error \(filePath)")
                break
            case .DownloadUnknownError(let filePath):
                print("Unknown Error \(filePath)")
                break
            case .DownloadDefaultError(let networkError, let filePath):
                print("didStopWithError error = \(networkError) \(filePath)")
                let alert = UIAlertController(title: "Download Failed", message: "If you want to download, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            default:
                print("Error: \(error). Unkown.")
                break
            }
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
