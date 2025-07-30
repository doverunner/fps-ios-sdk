//
//  FairPlayAdvancedTests.swift
//  FairPlayAdvanced
//
//  Created by DoveRunner on 2017. 7. 20..
//  Copyright © 2017년 DoveRunner. All rights reserved.
//

import XCTest

class FairPlayAdvancedTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAquireLicense() {
        let data = DownloadTestData.getData(fromURL: "", parameter: "", requestHeaders: ["pallycon-customdata-v2":"eyJkcm1fdHlwZSI6IkZhaXJQbGF5Iiwic2l0ZV9pZCI6IkRFTU8iLCJkYXRhIjoiTks3M0F0emZ0dG5sWkgvcU5FYlZsTTZFbzk2eVNhVEtSWlExSlNxN3Y4QTNPUi9xeUZTbVZ2QjV6THVVVlQxV09HS0lqTVRZT002eVdVdnZvMi9XRHZDV3hCbmk5YjJ6RWR4bHBkSGNJTXc9In0="])
        XCTAssert(data != nil)
    }
    
}
