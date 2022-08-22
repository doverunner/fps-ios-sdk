//
//  ViewController.swift
//  PallyConFPSSimple
//
//  Created by PallyCon on 2018. 4. 9..
//  Copyright © 2018년 inka. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
#if os(iOS)
import PallyConFPSSDK
#else
import PallyConFPSSDKTV
#endif

let pallyConSiteId  = ""
let pallyConSiteKey = ""
let pallyconToken   = ""
let contentPath     = ""

class ViewController: UIViewController {

    var fpsSDK: PallyConFPSSDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 1. Create PallyConFPSSDK instance.
        try? fpsSDK = PallyConFPSSDK(siteId: pallyConSiteId, siteKey: pallyConSiteKey, fpsLicenseDelegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let contentUrl = URL(string: contentPath) else {
            return
        }
        
        let urlAsset = AVURLAsset(url: contentUrl)
        
        // 2. Acquire a CustomData information
        fpsSDK?.prepare(urlAsset: urlAsset, token: pallyconToken)
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

extension ViewController: PallyConFPSLicenseDelegate
{
    func fpsLicenseDidSuccessAcquiring(contentId: String) {
        print("fpsLicenseDidSuccessAcquiring. (\(contentId))")
    }
    
    func fpsLicense(contentId: String, didFailWithError error: Error) {
        print("didFailWithError. error message (\(error.localizedDescription))")
        
        if let error = error as? PallyConSDKException {
            switch error {
            case .ServerConnectionFail(let message):
                print("server connection fail = \(message)")
            case .NetworkError(let networkError):
                print("Network Error = \(networkError)")
            case .AcquireLicenseFailFromServer(let code, let message):
                print("ServerCode = \(code).\n\(message)")
            case .DatabaseProcessError(let message):
                print("DB Error = \(message)")
            case .InternalException(let message):
                print("SDK internal Error = \(message)")
            default:
                print("Error: \(error). Unkown.")
                break
            }
        } else {
            print("Error: \(error). Unkown")
        }
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
