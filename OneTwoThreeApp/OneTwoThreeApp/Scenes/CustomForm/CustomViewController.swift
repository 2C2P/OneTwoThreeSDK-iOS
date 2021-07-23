//
//  CustomViewController.swift
//  OneTwoThreeApp
//
//  Created by Orawan Manasombun on 28/6/21.
//  Copyright (c) 2021 2C2P. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import OneTwoThreeSDK

protocol CustomDisplayLogic: AnyObject {
    func displayInitial(viewModel: Custom.Initial.ViewModel)
    func displayDeeplink(viewModel: Custom.StartDeeplink.ViewModel)
    func displayError(viewModel: Custom.Error.ViewModel)
}

class CustomViewController: BaseViewController, CustomDisplayLogic {
    
    var interactor: CustomBusinessLogic?
    var router: (NSObjectProtocol & CustomRoutingLogic & CustomDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = CustomInteractor()
        let presenter = CustomPresenter()
        let router = CustomRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        doInitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        setCustomRightBarButton(title: "Confirm")
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        if tableView.tableHeaderView == nil {
//            if tableHeaderView != nil {
//                tableHeaderView?.configure(viewController: self, title: "Production")
//                tableHeaderView?.delegate = self
//                tableView.tableHeaderView = tableHeaderView
//            }
//        }
        tableView.tableFooterView = UIView()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
//    private let tableHeaderView = FormHeaderView.loadFromNib() as? FormHeaderView
    
    private var inputTypes: [InputType] = []
    
    private var merchant: Merchant = Merchant()
    private var buyer: Buyer = Buyer()
    private var transaction: Transaction = Transaction()
    
    
    // MARK: - Configure
    
    private func configureUI() {
        title = "Custom"
        setDismissibleKeyboard()
        configureDefaultInfo()
    }
    
    override func onCustomRightBarButtonPressed() {
        view.endEditing(true)
        doStartDeeplink()
    }
    
    
    // MARK: - Private
    
    private func setDismissibleKeyboard() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func configureDefaultInfo() {
        merchant.id = "merchant@shopping.com"
        merchant.redirectURL = DeeplinkManager.shared.appScheme
        merchant.notificationURL = "https://uat2.123.co.th/DemoShopping/apicallurl.aspx"
        merchant.merchantData = [MerchantData(key: "item", value: "val1"), MerchantData(key: "item", value: "val2")]
        
        transaction.merchantReference = String.random(digits: 12)
        transaction.preferredAgent = "BAY"
        transaction.productDesc = "Description of the product."
        transaction.amount = "1"
        transaction.currencyCode = "THB"
        transaction.paymentExpiry = Date().add(months: 1)?.formatted(format: Constants.dateFormat)
        
        buyer.email = "siriporn@2c2p.com"
        buyer.mobile = "0878119880"
        buyer.language = "EN"
        buyer.notifyBuyer = true
        buyer.title = "Mr"
        buyer.firstName = "Bruce"
        buyer.lastName = "Wayne"
    }
    
    // MARK: - Initial
    
    func doInitial() {
        let request = Custom.Initial.Request()
        interactor?.doInitial(request: request)
    }
    
    func displayInitial(viewModel: Custom.Initial.ViewModel) {
        inputTypes = viewModel.types
        tableView.reloadData()
    }
    
    // MARK: - Start Deeplink
    
    func doStartDeeplink() {
        view.showLoading()
        let request = Custom.StartDeeplink.Request(merchant: merchant, transaction: transaction, buyer: buyer)
        interactor?.doStartDeeplink(request: request)
    }
    
    func displayDeeplink(viewModel: Custom.StartDeeplink.ViewModel) {
        view.hideLoading()
        
        if let deeplinkURL = viewModel.response?.deeplinkURL, let url = URL(string: deeplinkURL) {
            UIApplication.shared.open(url) { (result) in
                if result {
                    // The URL was delivered successfully!
                } else {
                    self.showAlertDialog(
                        title: "Unable to open bank app",
                        message: "Please ensure you have the app downloaded on your device."
                    )
                }
            }
        }
    }
    
    // MARK: - Error
    
    func displayError(viewModel: Custom.Error.ViewModel) {
        view.hideLoading()
        showAlertDialog(title: "Error", message: viewModel.error?.localizedDescription)
    }
    
}


// MARK: - TableView DataSouce & Delegate

extension CustomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let type = inputTypes[indexPath.row]
        
        if type == .merchantData {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InputTextViewCell", for: indexPath) as? InputTextViewCell else {
                return UITableViewCell()
            }
            if merchant.merchantData == nil {
                merchant.merchantData = []
            }
            cell.configure(inputType: type, value: transformMerchantData(merchantData: merchant.merchantData!))
            cell.delegate = self
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "InputTextFieldCell", for: indexPath) as? InputTextFieldCell else {
                return UITableViewCell()
            }
            
            cell.textField.isEnabled = (type != .merchantID)
            
            var value: String?
            
            switch type {
            case .merchantID:           value = merchant.id
            case .redirectURL:          value = merchant.redirectURL
            case .notificationURL:      value = merchant.notificationURL
            case .merchantData:         break
            
            case .merchantReference:    value = transaction.merchantReference
            case .perferredAgent:       value = transaction.preferredAgent
            case .productDesc:          value = transaction.productDesc
            case .paymentInfo:          value = transaction.paymentInfo
            case .amount:               value = transaction.amount
            case .currencyCode:         value = transaction.currencyCode
            case .paymentExpiry:        value = transaction.paymentExpiry
            case .userDefined1:         value = transaction.userDefined1
            case .userDefined2:         value = transaction.userDefined2
            case .userDefined3:         value = transaction.userDefined3
            case .userDefined4:         value = transaction.userDefined4
            case .userDefined5:         value = transaction.userDefined5
                
            case .buyerEmail:           value = buyer.email
            case .buyerMobile:          value = buyer.mobile
            case .buyerLanguage:        value = buyer.language
            case .buyerOS:              value = buyer.os
            case .buyerNotify:          value = (buyer.notifyBuyer ? "true" : "false")
            case .buyerTitle:           value = buyer.title
            case .buyerFirstName:       value = buyer.firstName
            case .buyerLastName:        value = buyer.lastName
            }
            
            cell.configure(value: value, type: type)
            cell.delegate = self
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputTypes.count
    }
}

extension CustomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = inputTypes[indexPath.row]
        return type == .merchantData ? 130 : 70
    }
}

// MARK: - InputTextFieldCell Delegate

extension CustomViewController: InputTextFieldCellDelegate {
    
    func updateValue(value: String, type: InputType) {
        switch type {
        case .merchantID:           merchant.id = value
        case .redirectURL:          merchant.redirectURL = value
        case .notificationURL:      merchant.notificationURL = value
        case .merchantData:         break
        
        case .merchantReference:    transaction.merchantReference = value
        case .perferredAgent:       transaction.preferredAgent = value
        case .productDesc:          transaction.productDesc = value
        case .paymentInfo:          transaction.paymentInfo = value
        case .amount:               transaction.amount = value
        case .currencyCode:         transaction.currencyCode = value
        case .paymentExpiry:        transaction.paymentExpiry = value
        case .userDefined1:         transaction.userDefined1 = value
        case .userDefined2:         transaction.userDefined2 = value
        case .userDefined3:         transaction.userDefined3 = value
        case .userDefined4:         transaction.userDefined4 = value
        case .userDefined5:         transaction.userDefined5 = value
            
        case .buyerEmail:           buyer.email = value
        case .buyerMobile:          buyer.mobile = value
        case .buyerLanguage:        buyer.language = value
        case .buyerOS:              buyer.os = value
        case .buyerNotify:          buyer.notifyBuyer = (value.lowercased() == "true")
        case .buyerTitle:           buyer.title = value
        case .buyerFirstName:       buyer.firstName = value
        case .buyerLastName:        buyer.lastName = value
        }
    }
}

// MARK: - InputTextViewCell Delegate

extension CustomViewController: InputTextViewCellDelegate {
    func updateValue(value: String) {
        merchant.merchantData = transformMerchantData(value: value)
    }
}

extension CustomViewController {
    func transformMerchantData(value: String) -> [MerchantData] {
        // eg. key:value,key:value  ->  MerchantData(key: "", value: "")
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "")
        let items = cleanValue.split(separator: ",")

        var merchantData: [MerchantData] = []
        
        for item in items {
            let separatedItem = item.split(separator: ":")
            let key = separatedItem[0]
            let value = separatedItem[1]
            let data = MerchantData(key: String(key), value: String(value))
            merchantData.append(data)
        }
        return merchantData
    }
    
    func transformMerchantData(merchantData: [MerchantData]) -> String {
        // eg. MerchantData(key: "", value: "")  ->  key:value,key:value
        let items: [String] = merchantData.compactMap({ "\($0.key ?? ""):\($0.value ?? "")" })
        return items.joined(separator: ",")
    }
}

// MARK: - FormHeaderView Delegate

extension CustomViewController: FormHeaderViewDelegate {
    func onTouchProductionSwitch() {
        merchant.id = Constants.merchantIDUAT
        tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
    }
}