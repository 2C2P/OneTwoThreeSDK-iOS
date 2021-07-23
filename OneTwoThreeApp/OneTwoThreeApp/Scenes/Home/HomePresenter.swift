//
//  HomePresenter.swift
//  OneTwoThreeApp
//
//  Created by Orawan Manasombun on 23/6/21.
//  Copyright (c) 2021 2C2P. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol HomePresentationLogic {
    func presentProducts(response: Home.GetProducts.Response)
    func presentPayment(response: Home.Payment.Response)
    func presentCustom(response: Home.Custom.Response)
}

class HomePresenter: HomePresentationLogic {
    
    weak var viewController: HomeDisplayLogic?
    
    // MARK: - Get Products
    
    func presentProducts(response: Home.GetProducts.Response) {
        let viewModel = Home.GetProducts.ViewModel(products: response.products)
        viewController?.displayProducts(viewModel: viewModel)
    }
    
    // MARK: - Navigate to Payment
    
    func presentPayment(response: Home.Payment.Response) {
        let viewModel = Home.Payment.ViewModel()
        viewController?.displayPayment(viewModel: viewModel)
    }
    
    
    // MARK: - Navigate to Custom
    
    func presentCustom(response: Home.Custom.Response) {
        let viewModel = Home.Custom.ViewModel()
        viewController?.displayCustom(viewModel: viewModel)
    }
    
}
