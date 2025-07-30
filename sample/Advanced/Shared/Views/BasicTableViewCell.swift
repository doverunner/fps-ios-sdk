//
//  Copyright © 2017년 DoveRunner INC. All rights reserved.
//
//  DoveRunner Team (http://www.doverunner.com)
//
//  BasicTableViewCell class is tableViewCell for the FPS Contents
//


import UIKit
import AVFoundation
import AVKit

#if os(iOS)
import DoveRunnerFairPlay
#else
import DoveRunnerFairPlayTV
#endif

class BasicTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "BasicTableViewCellIdentifier"
    
    @IBOutlet weak var contentNameLabel: UILabel!

#if os(iOS)
    @IBOutlet weak var downloadStatus: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
#endif
    weak var delegate: BasicTableViewCellDelegate?
    
#if os(iOS)
    var fpsContent: FPSContent? {
        didSet {
            if let fpsContent = fpsContent {    
                contentNameLabel.text = fpsContent.contentName
                if #available(iOS 11.0, *) {
                    let downloadState: FPSContent.DownloadState = SDKManager.sharedManager.downloadState(for: fpsContent)
                    switch downloadState {
                    case .downloaded, .notDownloaded:
                        downloadProgressView.isHidden = true
                    case .downloading, .pause:
                        downloadProgressView.isHidden = false
                    }
                    
                    downloadStatus.text = downloadState.rawValue
                    downloadProgressView.setProgress(0.0, animated: false)
                } else {
                    downloadStatus.text = ""
                }
            } else {
                contentNameLabel.text = ""
                
                downloadStatus.text = ""
                downloadProgressView.isHidden = false
            }
        }
    }
#elseif os(tvOS)
    var fpsContent: FPSContent? {
        didSet {
            if let fpsContent = fpsContent {
                contentNameLabel.text = fpsContent.contentName
            }
        }
    }
#endif
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleAcquireLicenseFailNotification(_:)), name: FPSAcquireLicenseFailNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(handleFPSDownloadProgressNotification(_:)), name: FPSDownloadProgressNotification, object: nil)
        #if os(iOS)
            notificationCenter.addObserver(self, selector: #selector(handleFPSDownloadStateChanagedNotification(_:)), name: FPSDownloadStateChangedNotification, object: nil)
        #endif

    }
    
    func removeObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: FPSAcquireLicenseFailNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: FPSDownloadProgressNotification, object: nil)
        #if os(iOS)
            notificationCenter.removeObserver(self, name: FPSDownloadStateChangedNotification, object: nil)
        #endif
    }
 
    @objc func handleFPSDownloadProgressNotification(_ notification: NSNotification) {
        guard let contentId = notification.userInfo![FPSContent.Keys.cId] as? String,
            let fpsContent: FPSContent = fpsContent,
            fpsContent.contentId == contentId,
            let progress = notification.userInfo![FPSContent.Keys.percentDownloaded] as? Double else {
            return
        }
        print("Downloading... Downloading... Downloading... Downloading... ")
        #if os(iOS)
            self.downloadProgressView.isHidden = false
            self.downloadProgressView.setProgress(Float(progress), animated: true)
        #endif
    }
    
#if os(iOS)
    @objc func handleFPSDownloadStateChanagedNotification(_ notification: NSNotification) {
        guard let contentId = notification.userInfo![FPSContent.Keys.cId] as? String,
            let downloadStateRawValue = notification.userInfo![FPSContent.Keys.downloadState] as? String,
            let downloadState = FPSContent.DownloadState(rawValue: downloadStateRawValue),
            self.fpsContent?.contentId == contentId else {
                return
        }
        
        DispatchQueue.main.async {
            switch downloadState {
            case .pause:
                if #available(iOS 11.0, *) {
                    SDKManager.sharedManager.pauseDownloadStatus(for: contentId)
                }
            case .downloading:
                self.downloadProgressView.isHidden = false
            case .downloaded, .notDownloaded:
                self.downloadProgressView.isHidden = true
            }
            
            self.downloadStatus.text = downloadState.rawValue
            print("\(downloadState.rawValue)")
            self.delegate?.basicListTableViewCell(self, downloadStateDidChange: downloadState)
        }

        guard let asset = notification.userInfo![FPSContent.Keys.avUrlAsset] as? AVURLAsset else {
            return
        }
        
        print("setting URL = \(asset.url.absoluteString)")
        self.delegate?.basicListTableViewCell(self, avPlayerAssetDidChange: asset)
    }
#endif
    
    @objc func handleAcquireLicenseFailNotification(_ notification: NSNotification) {
        guard let contentId = notification.userInfo![FPSContent.Keys.cId] as? String,
            self.fpsContent?.contentId == contentId,
            let token = fpsContent?.token,
            let contentName = fpsContent?.contentName,
            let error = notification.userInfo![FPSContent.Keys.acquireLicenseFail] as? Error else {
            return
        }
        
        var errorMessage = ""
        if let error = error as? SDKError {
            switch error {
            case .database(comment: let comment):
                errorMessage = comment
            case .server(errorCode: let errorCode, comment: let comment):
                errorMessage = "code : \(errorCode), comment: \(comment)"
            case .network(errorCode: let errorCode, comment: let comment):
                errorMessage = "code : \(errorCode), comment: \(comment)"
            case .system(errorCode: let errorCode, comment: let comment):
                errorMessage = "code : \(errorCode), comment: \(comment)"
            case .failed(errorCode: let errorCode, comment: let comment):
                errorMessage = "code : \(errorCode), comment: \(comment)"
            case .unknown(errorCode: let errorCode, comment: let comment):
                errorMessage = "code : \(errorCode), comment: \(comment)"
            case .invalid(comment: let comment):
                errorMessage = "comment: \(comment)"
            default:
                errorMessage = "comment: \(error)"
                break
            }
        }
        
        // a error handling when acquire license.
        let alertView = UIAlertController(title: "License Failed", message: errorMessage, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { Void in
            if #available(iOS 11.0, *), let newFpsContent = SDKManager.sharedManager.localFpsContentForStream(with: contentId, token: token, contentName: contentName) {
                self.delegate?.basicListTableViewCell(self, avPlayerAssetDidChange: newFpsContent.urlAsset)
            } else {
                if let originalAsset = FPSListManager.sharedManager.getContentUrlAsset(contentId: contentId) {
                    self.delegate?.basicListTableViewCell(self, avPlayerAssetDidChange: originalAsset)
                }
            }
        })
        DispatchQueue.main.async {
        if let topController = UIApplication.topViewController() {
            topController.present(alertView, animated: true, completion: nil)
        }
        }
    }
}

protocol BasicTableViewCellDelegate: AnyObject {
    func basicListTableViewCell(_ cell: BasicTableViewCell, downloadStateDidChange newState: FPSContent.DownloadState)
    func basicListTableViewCell(_ cell: BasicTableViewCell, avPlayerAssetDidChange asset: AVURLAsset)
}
