//
//  Copyright © 2017년 INKA ENTWORKS INC. All rights reserved.
//
//  PallyCon Team (http://www.pallycon.com)
//
//  A FPSPlaybackManager class handles playback in the AVPlayerViewController.
//


import UIKit
import AVFoundation

class FPSPlaybackManager: NSObject {
    // MARK: Properties
    /// Singleton for FPSPlaybackManager.
    static let sharedManager = FPSPlaybackManager()
    
    weak var delegate: FPSPlaybackDelegate?
    
    /// The instance of AVPlayer that will be used for playback of FPSPlaybackManager.playerItem.
    private let player = AVPlayer()
    
    /// A Bool tracking if the AVPlayerItem.status has changed to .readyToPlay for the current FPSPlaybackManager.playerItem.
    private var readyForPlayback = false
    
    private let notificationCenter = NotificationCenter.default
    
    /// The `NSKeyValueObservation` for the KVO on \AVPlayerItem.status.
    private var playerItemObserver: NSKeyValueObservation?
    
    /// The `NSKeyValueObservation` for the KVO on \AVURLAsset.isPlayable.
    private var urlAssetObserver: NSKeyValueObservation?
    
    /// The `NSKeyValueObservation` for the KVO on \AVPlayer.currentItem.
    private var playerObserver: NSKeyValueObservation?
   
    /// The AVPlayerItem associated with FPSPlaybackManager.urlAsset
    private var playerItem: AVPlayerItem? {
        willSet {
            /// Remove any previous KVO observer.
            guard let playerItemObserver = playerItemObserver else { return }
            
            playerItemObserver.invalidate()
            notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        }
        
        didSet {
            playerItemObserver = playerItem?.observe(\AVPlayerItem.status, options: [.new, .initial]) { [weak self] (item, _) in
                guard let strongSelf = self else { return }
                
                if item.status == .readyToPlay {
                    if !strongSelf.readyForPlayback {
                        strongSelf.readyForPlayback = true
                        strongSelf.delegate?.playbackManager(strongSelf, playerReadyToPlay: strongSelf.player)
                    }
                } else if item.status == .failed {
                    let error = item.error
                    print("AVPlayerItem Error: \(String(describing: error?.localizedDescription))")
                    let errorLog = item.errorLog()
                    let lastErrorEvent = errorLog?.events.last
                    print("ErrorLog: \(String(describing: lastErrorEvent?.description))")
                    strongSelf.delegate?.playbackManager(strongSelf, playerFail: strongSelf.player, fpsContent: strongSelf.fpsContent, error: error)
                }
            }
            notificationCenter.addObserver(self, selector: #selector(addMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }
    
    /// The Asset that is currently being loaded for playback.
    private var fpsContent: FPSContent? {
        willSet {
            /// Remove any previous KVO observer.
            guard let urlAssetObserver = urlAssetObserver else { return }
            
            urlAssetObserver.invalidate()
        }
        
        didSet {
            if let fpsContent = fpsContent {
                urlAssetObserver = fpsContent.urlAsset.observe(\AVURLAsset.isPlayable, options: [.new, .initial]) { [weak self] (urlAsset, _) in
                    guard let strongSelf = self, urlAsset.isPlayable == true else { return }
                    
                    strongSelf.playerItem = AVPlayerItem(asset: urlAsset)
                    strongSelf.player.replaceCurrentItem(with: strongSelf.playerItem)
                }
            }
            else {
                playerItem = nil
                player.replaceCurrentItem(with: nil)
                readyForPlayback = false
            }
        }
    }
    
    // MARK: Intitialization
    override private init() {
        super.init()
        
        playerObserver = player.observe(\AVPlayer.currentItem, options: [.new]) { [weak self] (player, _) in
            guard let strongSelf = self else { return }
            
            strongSelf.delegate?.playbackManager(strongSelf, playerCurrentItemDidChange: player)
        }
        
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem))
        /// Remove any KVO observer.
        playerObserver?.invalidate()
    }
    
    /**
     Replaces the currently playing `FPSContent`, if any, with a new `FPSContent`. If nil
     is passed, `FPSPlaybackManager` will handle unloading the existing `FPSContent`
     and handle KVO cleanup.
     */
    func setFpsContentForPlayback(_ fpsContent: FPSContent?) {
        readyForPlayback = false
        self.fpsContent = fpsContent
        /**
         When an iOS device is in AirPlay mode, FPS content will not play on an attached
         Apple TV unless AirPlay playback is set to mirroring. The FPS-aware app must set the
         usesExternalPlaybackWhileExternalScreenIsActive property of the AVPlayer object to TRUE.
        **/
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
    
    @objc func addMovedToBackground() {
        readyForPlayback = true
        self.setFpsContentForPlayback(self.fpsContent)
    }
}

#if os(iOS)
extension FPSPlaybackManager: URLSessionDelegate {
    
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let completionHandler = appDelegate.backgroundSessionCompletionHandler {
            appDelegate.backgroundSessionCompletionHandler = nil
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
}
#endif

/// FPSPlaybackDelegate provides a common interface for FPSPlaybackManager to provide callbacks to its delegate.
protocol FPSPlaybackDelegate: class {
    
    /// This is called when the internal AVPlayer in FPSPlaybackManager is ready to start playback.
    func playbackManager(_ playbackManager: FPSPlaybackManager, playerReadyToPlay player: AVPlayer)
    
    /// This is called when the internal AVPlayer's currentItem has changed.
    func playbackManager(_ playbackManager: FPSPlaybackManager, playerCurrentItemDidChange player: AVPlayer)
    
    /// This is called when the internal AVPlayer in FPSPlaybackManager is failed to play playback
    func playbackManager(_ playbackManager: FPSPlaybackManager, playerFail player: AVPlayer, fpsContent: FPSContent?, error: Error?)
}
