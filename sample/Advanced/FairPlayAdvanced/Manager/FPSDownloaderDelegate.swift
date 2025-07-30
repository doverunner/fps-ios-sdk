//
//  Copyright © 2017년 DoveRunner INC. All rights reserved.
//
//  DRM Team
//
//  MARK: This class is sample using DoveRunnerFairPlay.
//  A FPSDownloaderDelegate class leverages DoveRunnerFairPlay to download FPS content.
//

import Foundation
import AVFoundation
import DoveRunnerFairPlay

@available(iOS 11.2, *)
public class FPSDownloaderDelegate: NSObject {
    
    fileprivate var downloadTask: DownloadTask?
    
    init(url: URL, contentId: String, token: String) {
        super.init()

        let videoAsset = AVURLAsset(url: url)
        let config = FairPlayConfiguration(avURLAsset: videoAsset,
                                              contentId: contentId,
                                              certificateUrl: CERTIFICATE_URL,
                                              authData: token,
                                              delegate: SDKManager.sharedManager)
        downloadTask = SDKManager.sharedManager.doverunnerSdk?.createDownloadTask(drm: config, delegate: self)
    }
    
    init(url: URL, contentId: String, token: String, minimumBitrate: String ) {
        super.init()
        let videoAsset = AVURLAsset(url: url)
        let config = FairPlayConfiguration(avURLAsset: videoAsset,
                                              contentId: contentId,
                                              certificateUrl: CERTIFICATE_URL,
                                              authData: token,
                                              delegate: SDKManager.sharedManager)
        downloadTask = SDKManager.sharedManager.doverunnerSdk?.createDownloadTask(drm: config, delegate: self, downloadMinimumBitrate: minimumBitrate)
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
extension FPSDownloaderDelegate: FairPlayDownloadDelegate {
    public func downloadContent(_ contentId: String, didStartDownloadWithAsset asset: AVURLAsset, subtitleDisplayName: String) {
        print("didStartDownloadWithAsset contentId = \(contentId), displayName = \(subtitleDisplayName)")
        let userInfo: [String: Any] = [FPSContent.Keys.cId: contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.downloading.rawValue,
                                       FPSContent.Keys.avUrlAsset: asset]
        NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo: userInfo)
    }
    
    public func downloadContent(_ contentId: String, didStopWithError error:Error?) {
        print("didStopWithError contentId = \(contentId)")
       
        if let downloadError = error as NSError? {
            let userInfo: [String: Any] = [
                FPSContent.Keys.cId: contentId,
                FPSContent.Keys.downloadState: FPSContent.DownloadState.pause.rawValue
            ]
            NotificationCenter.default.post(name: FPSDownloadStateChangedNotification, object: nil, userInfo: userInfo)
            
            switch downloadError.code {
                case NSURLErrorCancelled:
                    // User cancellation is not a typical error, so no additional handling needed.
                    break
                case NSURLErrorNetworkConnectionLost:
                    showErrorAlert(title: "Network Error", message: "Connection was lost. Please try again.")
                case NSURLErrorTimedOut:
                    showErrorAlert(title: "Timeout Error", message: "Request timed out. Please try again later.")
                case NSURLErrorUnknown:
                    let detailedMessage = "Unknown error: \(downloadError.domain)\nCode: \(downloadError.code)\nDetails: \(downloadError.localizedDescription)"
                    showErrorAlert(title: "Download Failed", message: detailedMessage)
                default:
                    showErrorAlert(title: "Download Failed", message: "Error: \(downloadError.localizedDescription)")
            }
        }
    }
    
    public func downloadContent(_ contentId: String, didFinishDownloadingTo location: URL)  {
        print("didFinishDownloadingTo contentId = \(contentId)")
        let userDefaults = UserDefaults.standard
        var userInfo: [String: Any] = [FPSContent.Keys.cId:contentId, FPSContent.Keys.downloadState: FPSContent.DownloadState.downloaded.rawValue]
        userDefaults.set(location.relativePath, forKey: contentId)
        
        let contentUrl =  SDKManager.baseDownloadURL.appendingPathComponent(location.relativePath)
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
    
    private func showErrorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
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

