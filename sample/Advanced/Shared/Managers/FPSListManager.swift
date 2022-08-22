//
//  Copyright © 2017년 INKA ENTWORKS INC. All rights reserved.
//
//  PallyCon Team (http://www.pallycon.com)
//
//  A FPSListManager class is the list manager for FPS content
//

import Foundation
import AVFoundation

class FPSListManager: NSObject {
    // MARK: Properties
    /// A singleton instance of FPSListManager.
    static let sharedManager = FPSListManager()
    
    /// Notification for when download progress has changed.
    static let didLoadNotification = NSNotification.Name(rawValue: "FPSListManagerDidLoadNotification")
    
    /// The internal array of FPSContent structs.
    private var streamingOnlyContents = [FPSContent]()
    private var contents = [FPSContent]()
    
    fileprivate let baseDownloadURL: URL
    
    // MARK: Initialization
    override private init() {
        baseDownloadURL = URL(fileURLWithPath: NSHomeDirectory())
        
        super.init()
        
        guard let contentsFilepath = Bundle.main.path(forResource: "Contents", ofType: "plist") else { return }
        
        // Create an array from the contents of the Streams.plist file.
        guard let arrayOfStreams = NSArray(contentsOfFile: contentsFilepath) as? [[String: AnyObject]] else { return }
        
        // Iterate over each dictionary in the array.
        for entry in arrayOfStreams {
            // Get the Stream name from the dictionary
            guard let contentName = entry["ContentNameKey"] as? String,
                let contentPlaylistURLString = entry["ContentURL"] as? String else { continue }
            
            let contentId = (entry[FPSContent.Keys.cId] as? String) ?? ""
            let optionalId = (entry[FPSContent.Keys.optionalId] as? String) ?? ""
            let token = (entry[FPSContent.Keys.token] as? String) ?? ""
            let liveKeyRotation = (entry[FPSContent.Keys.liveKeyRotation] as? Bool) ?? false
            let chromcastUrlPath = (entry[FPSContent.Keys.chromcastPlayUrlPath] as? String) ?? ""
            let mainm3u8Scheme = (entry[FPSContent.Keys.mainm3u8Scheme] as? Bool) ?? false

            var fpsContent: FPSContent!
            // Get the FPSContent from
            if #available(iOS 11.0, *), let fpsContent = PallyConSDKManager.sharedManager.localFpsContentForStream(with: contentId, optionalId: optionalId, token: token, contentName: contentName) {
                self.contents.append(fpsContent)
                continue
            } else {
                // MARK: ADAPT: YOU MUST MODIFIER Contents.plist
                guard let contentPlaylistURL = URL(string: contentPlaylistURLString) else {
                    continue
                }
                var urlAsset: AVURLAsset
                if mainm3u8Scheme {
                    guard let mainm3u8SchemeUrl = replaceURLWithScheme("https", contentPlaylistURL ) else {
                        continue
                    }
                    urlAsset = AVURLAsset(url: mainm3u8SchemeUrl)
                } else {
                    urlAsset = AVURLAsset(url: contentPlaylistURL)
                }

                fpsContent = FPSContent(contentId, optionalId, token, liveKeyRotation, contentName, urlAsset, chromcastUrlPath, nil)
            }
            
            if let isOnlyStreaming = entry["OnlyStreaming"] as? Bool, isOnlyStreaming {
                self.streamingOnlyContents.append(fpsContent)
            } else {
                self.contents.append(fpsContent)
            }
        }
        
        NotificationCenter.default.post(name: FPSListManager.didLoadNotification, object: self)
    }
    
    func replaceURLWithScheme(_ scheme: String, _ url: URL) -> URL? {
        let urlString = url.absoluteString
        guard let index = urlString.firstIndex(of: ":") else { return nil }
        let rest = urlString[index...]
        let newUrlString = scheme + rest
        return URL(string: newUrlString)
    }
    
    // MARK: FPSContent access
    /// Returns the number of FPSContent.
    func numberOfContent(section: Int) -> Int {
        if section == 0 {
            // streaming only
            return self.streamingOnlyContents.count
        } else {
            #if os(iOS)
                return self.contents.count
            #else
                // the apple tv only support streaming.
                return 0
            #endif
        }
    }
    
    /// Returns an FPSContent for a given IndexPath.
    func fpsContent(section: Int, index: Int) -> FPSContent {
        if section == 0 {
            // streaming only
            return self.streamingOnlyContents[index]
        } else {
            return self.contents[index]
        }
    }
    
    /// Set an FPSContent for a given IndexPath.
    func setUrlAsset(for section: Int, index: Int, urlAsset: AVURLAsset) {
        if section == 0 {
            // streaming only
            self.streamingOnlyContents[index].urlAsset = urlAsset
        } else {
            self.contents[index].urlAsset = urlAsset
        }
    }
    
    /// Returns an AVURLAsset for a given contentId in Contents list.
    func getContentUrlAsset(contentId: String) -> AVURLAsset? {
        var urlAsset: AVURLAsset?
        
        guard let contentsFilepath = Bundle.main.path(forResource: "Contents", ofType: "plist") else { return nil }
        
        // Create an array from the contents of the Streams.plist file.
        guard let arrayOfStreams = NSArray(contentsOfFile: contentsFilepath) as? [[String: AnyObject]] else { return nil }
        
        // Iterate over each dictionary in the array.
        for entry in arrayOfStreams {
            // Get the Stream name from the dictionary
            guard let contentPlaylistURLString = entry["ContentURL"] as? String,
                let cId = entry[FPSContent.Keys.cId] as? String else { continue }
            
            if cId == contentId  {
                let contentPlaylistURL = URL(string: contentPlaylistURLString)!
                urlAsset = AVURLAsset(url: contentPlaylistURL)
            } else {
                continue
            }
        }
        
        return urlAsset
    }
}
