//
//  FairPlayAdvancedUITests.swift
//  FairPlayAdvancedUITests
//
//  Created by DRM Team on 2018. 1. 30..
//  Copyright © 2018년 DoveRunner. All rights reserved.
//

import XCTest
import AVKit

class FairPlayAdvancedUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
         super.setUp()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
        
        app.launchArguments.append("--uitesting")
        
        app.launch()
    }
    
    func testPlayTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 0)
        cellElement.tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Basic Sample"].exists)
        XCTAssertTrue(app.buttons["Pause"].exists)
    }
    
    func testIncorrectPlayTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 1)
        cellElement.tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Basic Sample"].exists)
        XCTAssertFalse(app.buttons["Pause"].exists)
    }
    
    func testFullPlayTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 0)
        cellElement.tap()
        
        let backButton = app.navigationBars.buttons["Basic Sample"]
        XCTAssertTrue(backButton.exists)
        
        sleep(5)
        
        let playButton = app.buttons["Play"]
        let predicate = NSPredicate(format: "exists == true")
        let expection = expectation(for: predicate, evaluatedWith: playButton, handler: nil)
        let result = XCTWaiter.wait(for: [expection], timeout: 700)
        XCTAssertTrue(result == .completed)
    }
    
    func testSeekingTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 0)
        cellElement.tap()
        
        let backButton = app.navigationBars.buttons["Basic Sample"]
        XCTAssertTrue(backButton.exists)
        
        sleep(5)
        
        let videoElement = app.otherElements["Video"]
        let currentPositionSlider = app.sliders["Current position"]
        
        let pauseButton = app.buttons["Pause"]
        let predicate = NSPredicate(format: "exists == true")
        let expection = expectation(for: predicate, evaluatedWith: pauseButton, handler: nil)
        
        for _ in 1...5 {
            videoElement.tap()
            currentPositionSlider.adjust(toNormalizedSliderPosition: 0.8)
            sleep(5)
            videoElement.tap()
            var result = XCTWaiter.wait(for: [expection], timeout: 2)
            XCTAssertTrue(result == .completed)
            
            videoElement.tap()
            currentPositionSlider.adjust(toNormalizedSliderPosition: 0.3)
            sleep(5)
            videoElement.tap()
            result = XCTWaiter.wait(for: [expection], timeout: 2)
            XCTAssertTrue(result == .completed)
        }
    }
    
    func testStressPlayTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 0)
        let cellElement2 = cells.element(boundBy: 1)
        
        let pauseButton = app.buttons["Pause"]
        let predicate = NSPredicate(format: "exists == true")
        let expection = expectation(for: predicate, evaluatedWith: pauseButton, handler: nil)
        
        for _ in 1...5 {
            cellElement.tap()
            sleep(5)
            
            let videoElement = app.otherElements["Video"]
            videoElement.tap()
            var result = XCTWaiter.wait(for: [expection], timeout: 2)
            XCTAssertTrue(result == .completed)
            
            let backButton = app.navigationBars.buttons["Basic Sample"]
            backButton.tap()
            
            cellElement2.tap()
            XCTAssertTrue(backButton.exists)
            XCTAssertTrue(pauseButton.exists)
            sleep(5)
            
            videoElement.tap()
            result = XCTWaiter.wait(for: [expection], timeout: 2)
            XCTAssertTrue(result == .completed)
            backButton.tap()
        }
    }
    
    func testDownloadTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 0)
        let sheetElement = app.sheets.element(boundBy: 0)
        let labelString = cellElement.label
        
        if labelString.contains("downloaded") {
            cellElement.buttons["More Info"].tap()
            sheetElement.buttons["Delete"].tap()
        }
        
        cellElement.buttons["More Info"].tap()
        XCTAssertTrue(sheetElement.buttons["Download"].exists)
        
        sheetElement.buttons["Download"].tap()
        
        sleep(5)
        
        let downloadProgress = cellElement.progressIndicators.element(boundBy: 0)
        XCTAssertTrue(downloadProgress.exists)
        let predicate = NSPredicate(format: "exists == false")
        let expection = expectation(for: predicate, evaluatedWith: downloadProgress, handler: nil)
        let result = XCTWaiter.wait(for: [expection], timeout: 150)
        XCTAssertTrue(result == .completed)
    }
    
    func testDownloadPauseTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 0)
        let sheetElement = app.sheets.element(boundBy: 0)
        let labelString = cellElement.label
        
        if labelString.contains("downloaded") {
            cellElement.buttons["More Info"].tap()
            sheetElement.buttons["Delete"].tap()
        }
        
        cellElement.buttons["More Info"].tap()
        XCTAssertTrue(sheetElement.buttons["Download"].exists)
        
        sheetElement.buttons["Download"].tap()
        
        sleep(5)
        
        let downloadProgress = cellElement.progressIndicators.element(boundBy: 0)
        XCTAssertTrue(downloadProgress.exists)
        
        cellElement.buttons["More Info"].tap()
        XCTAssertTrue(sheetElement.buttons["Pause"].exists)
        sheetElement.buttons["Pause"].tap()
        
        sleep(1)
        
        cellElement.buttons["More Info"].tap()
        XCTAssertTrue(sheetElement.buttons["Download"].exists)
        sheetElement.buttons["Download"].tap()
        
        let predicate = NSPredicate(format: "exists == false")
        let expection = expectation(for: predicate, evaluatedWith: downloadProgress, handler: nil)
        let result = XCTWaiter.wait(for: [expection], timeout: 150)
        XCTAssertTrue(result == .completed)
    }
    
    func testDownloadPlayTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 0)
        let sheetElement = app.sheets.element(boundBy: 0)
        let labelString = cellElement.label
        
        TestCaseUtil.connectedWifi()
        
        if labelString.contains("downloaded") == false {
            cellElement.buttons["More Info"].tap()
            XCTAssertTrue(sheetElement.buttons["Download"].exists)
            
            sheetElement.buttons["Download"].tap()
            
            sleep(5)
            
            let downloadProgress = cellElement.progressIndicators.element(boundBy: 0)
            XCTAssertTrue(downloadProgress.exists)
            let predicate = NSPredicate(format: "exists == false")
            let expection = expectation(for: predicate, evaluatedWith: downloadProgress, handler: nil)
            let result = XCTWaiter.wait(for: [expection], timeout: 150)
            XCTAssertTrue(result == .completed)
        }
        
        cellElement.tap()
        
        let videoElement = app.otherElements["Video"]
        XCTAssertTrue(app.navigationBars.buttons["Basic Sample"].exists)
        if app.buttons["Pause"].exists == false {
            videoElement.tap()
        }
        XCTAssertTrue(app.buttons["Pause"].exists)
        app.navigationBars.buttons["Basic Sample"].tap()
        
        TestCaseUtil.toggleWiFi()
        
        // 오프라인 재생 테스트
        cellElement.tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Basic Sample"].exists)
        XCTAssertTrue(app.buttons["Pause"].exists)
        app.navigationBars.buttons["Basic Sample"].tap()
        
        TestCaseUtil.toggleWiFi()
    }
    
    func testLicenseExpireOfTheContent() {
        let tables = app.tables
        let cells = tables.cells
        let cellElement = cells.element(boundBy: 1)
        let sheetElement = app.sheets.element(boundBy: 0)
        let labelString = cellElement.label
        
        TestCaseUtil.connectedWifi()
        
        if labelString.contains("downloaded") == false {
            cellElement.buttons["More Info"].tap()
            XCTAssertTrue(sheetElement.buttons["Download"].exists)
            
            sheetElement.buttons["Download"].tap()
            
            sleep(5)
            
            let downloadProgress = cellElement.progressIndicators.element(boundBy: 0)
            XCTAssertTrue(downloadProgress.exists)
            let predicate = NSPredicate(format: "exists == false")
            let expection = expectation(for: predicate, evaluatedWith: downloadProgress, handler: nil)
            let result = XCTWaiter.wait(for: [expection], timeout: 150)
            XCTAssertTrue(result == .completed)
        } else {
            cellElement.buttons["More Info"].tap()
            sheetElement.buttons["Remove License"].tap()
        }

        cellElement.tap()
        
        let videoElement = app.otherElements["Video"]
        XCTAssertTrue(app.navigationBars.buttons["Basic Sample"].exists)
        if app.buttons["Pause"].exists == false {
            videoElement.tap()
        }
        XCTAssertTrue(app.buttons["Pause"].exists)
        app.navigationBars.buttons["Basic Sample"].tap()
        
        TestCaseUtil.toggleWiFi()
        
        // 오프라인 재생 테스트
        cellElement.tap()
        
        XCTAssertTrue(app.navigationBars.buttons["Basic Sample"].exists)
        XCTAssertTrue(app.buttons["Pause"].exists)
        app.navigationBars.buttons["Basic Sample"].tap()
        
        sleep(60)
        
        cellElement.tap()
        
        let playFailedAlert = app.alerts["Play Failed"]
        XCTAssertTrue(playFailedAlert.buttons["Ok"].exists)
        
        playFailedAlert.buttons["Ok"].tap()
        app.navigationBars.buttons["Basic Sample"].tap()
        
        TestCaseUtil.toggleWiFi()        
    }
}

