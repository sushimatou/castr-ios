//
//  Preprod_CastrAppTests.swift
//  Preprod-CastrAppTests
//
//  Created by Antoine on 09/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import XCTest
@testable import Preprod_CastrApp

class Preprod_CastrAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateDateSectionsList() {
        
        let timestamp1 = Double(1510227602747)
        let timestamp2 = Double(1510220002503)
        
        let message1 = MessageDto(id: "0", type: .infoMessage(text: "test"), createdAt: timestamp1)
        let message2 = MessageDto(id: "1", type: .infoMessage(text: "test"), createdAt: timestamp2)
        let message3 = MessageDto(id: "2", type: .infoMessage(text: "test"), createdAt: timestamp2)

        let supposedDateSection1 = DateHelper.getStringFromDate(date: Date(timeIntervalSince1970: timestamp1/1000))
        let supposedDateSection2 = DateHelper.getStringFromDate(date: Date(timeIntervalSince1970: timestamp2/1000))
        
        let dateList = MessagingSorting
            .createDateSectionsListByMessages(messages: [message1, message2, message3])
        
        if supposedDateSection1 == supposedDateSection2 {
            XCTAssertEqual(dateList, [supposedDateSection1])
        }
        
        else {
            XCTAssertEqual(dateList, [supposedDateSection1, supposedDateSection2])
        }
        
    }
    
    func testGroupMessageByDateSections() {
        
    }
    
}
