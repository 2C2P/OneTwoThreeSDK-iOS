//
//  PaymentInteractor.swift
//  OneTwoThreeApp
//
//  Created by Orawan Manasombun on 24/6/21.
//  Copyright (c) 2021 2C2P. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import OneTwoThreeSDK

protocol PaymentBusinessLogic {
    func doInitial(request: Payment.Initial.Request)
    func doStartDeeplink(request: Payment.StartDeeplink.Request)
}

protocol PaymentDataStore {
    var product: Product? { get set }
}

class PaymentInteractor: PaymentBusinessLogic, PaymentDataStore {
    
    var presenter: PaymentPresentationLogic?
    var worker: PaymentWorker?
    
    var product: Product?
    
    // MARK: - Initial
    
    func doInitial(request: Payment.Initial.Request) {
        worker = PaymentWorker()
        worker?.doSomeWork()
        
        let response = Payment.Initial.Response(product: product)
        presenter?.presentInitial(response: response)
    }
    
    // MARK: - Start Deeplink
    
    func doStartDeeplink(request: Payment.StartDeeplink.Request) {
        guard let product = self.product, let paymentMethod = request.paymentMethod else {
            let response = Payment.Error.Response(error: ErrorEvent.missingParams)
            self.presenter?.presentError(response: response)
            return
        }
        
        let merchant = Merchant(
            id: Constants.merchantID,
            redirectURL: DeeplinkManager.shared.appScheme,
            notificationURL: "https://uat2.123.co.th/DemoShopping/apicallurl.aspx",
            merchantData: [
                MerchantData(key: "item", value: "943-cnht302gg"),
                MerchantData(key: "item", value: "FH403"),
                MerchantData(key: "item", value: "10,000.00"),
                MerchantData(key: "item", value: "Ref. 43, par. 7")
            ]
        )
        let transaction = Transaction(
            merchantReference: String.random(digits: 12),
            preferredAgent: paymentMethod.abbreviation,
            productDesc: product.desc ?? "",
            amount: product.amount ?? "0",
            currencyCode: "THB",
            paymentExpiry: Date().add(months: 3)?.formatted(format: Constants.dateFormat)
        )
        let buyer = Buyer(
            email: "example@email.com",
            mobile: "0987654321",
            language: "EN",
            notifyBuyer: true,
            title: "Mr",
            firstName: "John",
            lastName: "Doe"
        )
        Manager.shared.service.startDeeplink(merchant: merchant, transaction: transaction, buyer: buyer) { response in
            
            if response.responseCode == ResponseCode.success {
                let response = Payment.StartDeeplink.Response(response: response)
                self.presenter?.presentDeeplink(response: response)
                
            } else {
                let response = Payment.Error.Response(error: ErrorEvent.custom(message: response.responseDesc))
                self.presenter?.presentError(response: response)
            }
            
        } failureBlock: { error in
            let response = Payment.Error.Response(error: ErrorEvent.custom(message: error.localizedDescription))
            self.presenter?.presentError(response: response)
        }
    }
}
