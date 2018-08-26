//
//  VoiceItApi2IosSDK_ExampleTests.swift
//  VoiceItApi2IosSDK_ExampleTests
//
//  Created by Armaan Bindra on 8/26/18.
//  Copyright © 2018 armaanbindra. All rights reserved.s

import UIKit
import XCTest
@testable import VoiceItApi2IosSDK

struct VoiceItResponse: Decodable {
    let responseCode: String
    let message: String
    let status: Int
}

class VoiceItTest : XCTestCase {
    var myVoiceIt:VoiceItAPITwo?
    var viewController: UIViewController!
    var VI_API_KEY: String?
    var VI_API_TOKEN: String?
    let TIMEOUT = 1000.0
    var started = false
    var counter = 0
    
    func getEnvironmentVar(_ name: String) -> String? {
        guard let rawValue = getenv(name) else { return nil }
        return String(utf8String: rawValue)
    }
    
    class func decodeSimpleJSON(jsonString: String) -> VoiceItResponse?{
        let jsonData = jsonString.data(using: .utf8)
        guard let ret = try? JSONDecoder().decode(VoiceItResponse.self, from: jsonData!) else {
            return nil
        }
        return ret
    }
    
    class func basicAssert(expectedRC: String, expectedSC: Int, jsonResponse : String){
        let ret = decodeSimpleJSON(jsonString: jsonResponse)!
        XCTAssertEqual(ret.responseCode, expectedRC)
        XCTAssertEqual(ret.status, expectedSC)
    }
    
    // Called once before all tests
    override func setUp() {
        if let viApiKey = getEnvironmentVar("VIAPIKEY") {
            VI_API_KEY = viApiKey
        }
        
        if let viApiTok = getEnvironmentVar("VIAPITOKEN") {
            VI_API_TOKEN = viApiTok
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        self.myVoiceIt  = VoiceItAPITwo(viewController, apiKey: VI_API_KEY, apiToken: VI_API_TOKEN)
    }
}

class VoiceItApi2IosSDK_Test: VoiceItTest {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUsers() {
        let expectation = XCTestExpectation(description: "Testing Get All Users")
        myVoiceIt?.getAllUsers({
            jsonResponse in
            VoiceItTest.basicAssert(expectedRC: "UNAC", expectedSC: 401, jsonResponse: jsonResponse!)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: TIMEOUT)
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
