//
//  OneTwoThreeAppTests.swift
//  OneTwoThreeAppTests
//
//  Created by Orawan Manasombun on 18/6/21.
//  Copyright © 2021 2C2P. All rights reserved.
//

import XCTest
import OneTwoThreeSDK

@testable import OneTwoThreeApp

class OneTwoThreeAppTests: XCTestCase {
    
    // TODO: Set the environment.
    private var production: Bool = false
    
    private var checksumKey: String {
        return production ? Constants.checksumKeyPROD : Constants.checksumKeyUAT
    }
    private var publicKey: String {
        return production ? Constants.publicKeyPROD : Constants.publicKeyUAT
    }
    private var privateKey: String {
        return production ? Constants.privateKeyPROD : Constants.privateKeyUAT
    }
    private var passphrase: String {
        return production ? Constants.passphrasePROD : Constants.passphraseUAT
    }
    
    var service: OneTwoThreeSDKService {
        return OneTwoThreeSDKService(
            production: production,
            checksumKey: checksumKey,
            publicKey: publicKey,
            privateKey: privateKey,
            passphrase: passphrase
        )
    }
    
    var startDeeplinkResponse: StartDeeplinkResponse?
    var getDeeplinkStatusResponse: GetDeeplinkStatusResponse?
    var cancelDeeplinkResponse: CancelDeeplinkResponse?
    
    // MARK: - Tests
    
    func testStartDeelink() throws {
        print("\nProduction ENV: \(production)\n")
        
        let merchant = Merchant( 
            id: production ? Constants.merchantIDPROD : Constants.merchantIDUAT,
            redirectURL: "onetwothreeapp://",
            notificationURL: "https://uat2.123.co.th/DemoShopping/apicallurl.aspx",
            merchantData: [
                MerchantData(key: "item", value: "943-cnht302gg"),
                MerchantData(key: "item_2", value: "FH403"),
                MerchantData(key: "item_3", value: "10,000.00"),
                MerchantData(key: "item_4", value: "Ref. 43, par. 7")
            ]
        )
        let transaction = Transaction(
            merchantReference: String.random(digits: 12),
            preferredAgent: "SCB",
            productDesc: "",
            amount: "1.00",
            currencyCode: "THB",
            paymentInfo: "",
            paymentExpiry: "2021-12-10 11:21:36"
        )
        let buyer = Buyer(
            email: "siriporn@2c2p.com",
            mobile: "0878119880",
            language: "EN",
            notifyBuyer: true,
            title: "Mr",
            firstName: "Bruce",
            lastName: "Wayne"
        )
        
        let expectation = self.expectation(description: "Call startDeeplink API successfully")
        
        service.startDeeplink(merchant: merchant, transaction: transaction, buyer: buyer) { response in
            self.startDeeplinkResponse = response
            
            XCTAssertEqual(response.responseCode, ResponseCode.success, "Start Deeplink API - request failed")
            XCTAssertEqual(response.merchant?.merchantData?.count, merchant.merchantData?.count, "Start Deeplink API - merchant data does not match")
            
            print("\n-- Start Deeplink Response --\n")
            print("responseCode: \(response.responseCode ?? "-")")
            print("responseDesc: \(response.responseDesc ?? "-")")
            print("payment code: \(response.transaction?.paymentCode ?? "-")")
            print("merchant data (count): \(response.merchant?.merchantData?.count ?? 0)")
            print("merchant data: \(response.merchant?.merchantData?.description ?? "-")")
            print("deeplink: \(response.deeplinkURL ?? "-")")
            print("\n------------------------\n")
            expectation.fulfill()
            
        } failureBlock: { error in
            print("error (start deeplink) - \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGetDeelinkStatus() throws {
        
        let expectation = self.expectation(description: "Call getDeeplinkStatus API successfully")
        
        let merchantID = "merchant@shopping.com"
        let paymentCode = "2916362466"
        let merchantReference = ""
        
        service.getDeeplinkStatus(merchantID: merchantID, paymentCode: paymentCode, merchantReference: merchantReference) { response in
            self.getDeeplinkStatusResponse = response
            
            XCTAssertEqual(response.responseCode, ResponseCode.success, "Get Deeplink Status API - request failed")
            
            print("\n-- Get Deeplink Response --\n")
            print("responseCode: \(response.responseCode ?? "-")")
            print("responseDesc: \(response.responseDesc ?? "-")")
            print("payment status: \(response.transaction?.paymentStatus ?? "-")")
            print("merchant data (count): \(response.merchant?.merchantData?.count ?? 0)")
            print("merchant data: \(response.merchant?.merchantData?.description ?? "-")")
            print("agent: \(response.agent.debugDescription)")
            print("\n------------------------\n")
            expectation.fulfill()
            
        } failureBlock: { error in
            print("error (get deeplink) - \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    func testCancelDeelink() throws {
        
        let expectation = self.expectation(description: "Call cancelDeeplink API successfully")
        
        let merchantID = "merchant@shopping.com"
        let merchantReference = ""
        let paymentCode = "2916362466"
        
        service.cancelDeeplink(merchantID: merchantID, paymentCode: paymentCode, merchantReference: merchantReference) { response in
            self.cancelDeeplinkResponse = response
            
            // TODO: For now only get '10 - Payment cannot be cancelled'
            XCTAssertNotEqual(response.responseCode, ResponseCode.failed, "Cancel Deeplink API - request failed")
            
            print("\n-- Cancel Deeplink Response --\n")
            print("responseCode: \(response.responseCode ?? "-")")
            print("responseDesc: \(response.responseDesc ?? "-")")
            print("\n------------------------\n")
            expectation.fulfill()
            
        } failureBlock: { error in
            print("error (get deeplink) - \(error.localizedDescription)")
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
