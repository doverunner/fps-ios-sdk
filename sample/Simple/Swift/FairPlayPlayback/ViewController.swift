//
//  ViewController.swift
//  DoveRunnerFairPlayPlayback Sample
//
//  Created by DRM Team on 2018. 4. 9..
//  Copyright © 2025 DoveRunner. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
#if os(iOS)
import DoveRunnerFairPlay
#else
import DoveRunnerFairPlayTV
#endif

let CERTIFICATE_URL  = "https://drm-license.doverunner.com/ri/fpsKeyManager.do?siteId=????"
let CONTENT_ID       = ""
let CONTENT_URL      = ""
let CONTENT_AUTHDATA = ""

class ViewController: UIViewController {

    var doverunnerSdk: DoveRunnerFairPlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 1. Create DoveRunnerFairPlay instance.
        doverunnerSdk = DoveRunnerFairPlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let contentUrl = URL(string: CONTENT_URL) else {
            return
        }
        
        let urlAsset = AVURLAsset(url: contentUrl)
        
        let config = FairPlayConfiguration(avURLAsset: urlAsset,
                                              contentId: CONTENT_ID,
                                              certificateUrl: CERTIFICATE_URL,
                                              authData: CONTENT_AUTHDATA)
        // 2. Acquire a CustomData information
        doverunnerSdk?.prepare(drm: config)
        let playerItem = AVPlayerItem(asset: urlAsset)
        let player = AVPlayer(playerItem: playerItem)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: FairPlayLicenseDelegate
{
    func license(result: LicenseResult) {
        print("---------------------------- License Result ")
        print("Content ID : \(result.contentId)")
        print("Key ID     : \(String(describing: result.keyId))")
        if result.isSuccess == false {
            print("Error : \(String(describing: result.error?.localizedDescription))")
            if let error = result.error {
                switch error {
                case .database(comment: let comment):
                    print(comment)
                case .server(errorCode: let errorCode, comment: let comment):
                    print("code : \(errorCode), comment: \(comment)")
                case .network(errorCode: let errorCode, comment: let comment):
                    print("code : \(errorCode), comment: \(comment)")
                case .system(errorCode: let errorCode, comment: let comment):
                    print("code : \(errorCode), comment: \(comment)")
                case .failed(errorCode: let errorCode, comment: let comment):
                    print("code : \(errorCode), comment: \(comment)")
                case .unknown(errorCode: let errorCode, comment: let comment):
                    print("code : \(errorCode), comment: \(comment)")
                case .invalid(comment: let comment):
                    print("comment: \(comment)")
                case .download(errorCode: let errorCode, comment: let comment):
                    print("code : \(errorCode), comment: \(comment)")
                @unknown default:
                    print("comment: unknown")
                }
            }
        }
    }

    /*
    func licenseCallback(with spcData: Data, httpHeader header: [String : String]?) -> Data? {
        guard let url = URL(string: "https://drm-license.doverunner.com/ri/licenseManager.do") else {
            return Data()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = header
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
