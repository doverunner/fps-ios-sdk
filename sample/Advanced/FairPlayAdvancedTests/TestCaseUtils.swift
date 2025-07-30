//
//  TestCaseUtils.swift
//  DoveRunnerFairPlay
//
//  Created by DoveRunner on 2017. 1. 20..
//  Copyright © 2017년 DoveRunner. All rights reserved.
//

import XCTest
@testable import DoveRunnerFairPlay

class TestCaseUtil: NSObject {
    
    static func connectedWifi() {
        let app = XCUIApplication()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        // open control center
        let coord1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
        let coord2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coord1.press(forDuration: 0.1, thenDragTo: coord2)
        
        if springboard/*@START_MENU_TOKEN@*/.switches["Wi-Fi, 연결 안 됨"]/*[[".switches[\"Wi-Fi, 연결 안 됨\"]",".switches[\"wifi-button\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.exists {
            let wifiButton = springboard.switches["wifi-button"]
            wifiButton.tap()
        }
        
        // close control center
        let coord3 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        coord3.tap()
    }
    
    static func toggleWiFi() {
        let app = XCUIApplication()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        // open control center
        let coord1 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.99))
        let coord2 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coord1.press(forDuration: 0.1, thenDragTo: coord2)
        
        let wifiButton = springboard.switches["wifi-button"]
        wifiButton.tap()
        
        // close control center
        let coord3 = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        coord3.tap()
    }
}

class DownloadTestData: NSObject  {
    static func getData(fromURL: String, parameter: String, requestHeaders: [String: String]) -> Data? {
        var request = URLRequest(url: URL(string: fromURL)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5.0)
        request.httpMethod = "GET"
        if parameter.characters.count > 0 {
            request.httpBody = parameter.data(using: .utf8)
        }
        
        for object in requestHeaders {
            print("HTTP Header Key: " + object.key + " Value: " + object.value)
            request.setValue(object.value, forHTTPHeaderField: object.key)
        }
        
        var resultData: Data?
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            resultData = data
            let httpURLResponse = response as? HTTPURLResponse
            print("response Result = \(String(describing: httpURLResponse?.statusCode))")
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return resultData
    }
}
