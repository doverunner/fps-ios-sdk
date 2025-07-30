//
//  Copyright © 2017년 DoveRunner INC. All rights reserved.
//
//  DoveRunner Team (http://www.doverunner.com)
//
//  FPSContent struct for FPS contents.
//

import AVFoundation
#if os(iOS)
import DoveRunnerFairPlay
#else
import DoveRunnerFairPlayTV
#endif


struct FPSContent {
    
    var keyId: String
    var contentId: String
    var token: String
    var liveKeyRotation: Bool
    var contentName: String
    var urlAsset: AVURLAsset
    var chromcastPlayUrlPath: String
    var downloadDelegate: Any?
    
    init(_ contentId: String,
         _ token: String,
         _ contentName: String,
         _ urlAsset: AVURLAsset
         ) {
        self.init("", contentId, token, false, contentName, urlAsset, "", nil)
    }
    
    init(_ keyId: String,
         _ contentId: String,
         _ token: String,
         _ liveKeyRotation: Bool,
         _ contentName: String,
         _ urlAsset: AVURLAsset,
         _ chromcastPlayUrlPath: String,
         _ downloadDelegate: Any?) {
        self.keyId = keyId
        self.contentId = contentId
        self.token = token
        self.liveKeyRotation = liveKeyRotation
        self.contentName = contentName
        self.urlAsset = urlAsset
        self.chromcastPlayUrlPath = chromcastPlayUrlPath
        self.downloadDelegate = downloadDelegate
    }
}

/// Extends `FPSContent` to conform to the `Equatable` protocol.
extension FPSContent: Equatable {}

func ==(lhs: FPSContent, rhs: FPSContent) -> Bool {
    return (lhs.contentId == rhs.contentId) && (lhs.urlAsset == rhs.urlAsset)
}

extension FPSContent {
    enum DownloadState: String {
        case notDownloaded
        
        case downloading
        
        case downloaded
        
        case pause
    }
}

extension FPSContent {
    struct Keys {
        
        static let keyId = "KeyId"
        
        static let cId = "FPSCidKey"
       
        static let token = "FPSToken"
        
        static let liveKeyRotation = "FPSLiveKeyRotation"
        
        static let avUrlAsset = "FPSAVURLAsset"
        
        static let downloadState = "FPSDownloadStateKey"
        
        static let percentDownloaded = "FPSPercentDownloadedKey"
        
        static let acquireLicenseFail = "FPSAcquireLicenseFail"
        
        static let chromcastPlayUrlPath = "ChromcastPlayUrlPath"
        
        static let mainm3u8Scheme = "Mainm3u8Scheme"
    }
}
