//
//  UserEditInfoViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/2/14.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class UserEditInfoViewController: UIViewController {
    
    var user: User!
    var postCodeInfos = [PostCodeInfo]()
    var orders = [Order]()
    lazy var cities = postCodeInfos.map({$0.City}).removingDuplicates()
    lazy var districts = postCodeInfos.filter({$0.City == postCodeInfos.first?.City}).map({$0.Area})
    lazy var postCodes = postCodeInfos.filter({$0.City == postCodeInfos.first?.City}).map({$0.ZipCode})
    var currentPostCode = ""
    
    @IBOutlet weak var recipientNameTextField: UITextField!
    @IBOutlet weak var recipientsPhoneTextField: UITextField!
    @IBOutlet weak var recipientCityTextField: UITextField!
    @IBOutlet weak var recipientDistrictTextField: UITextField!
    @IBOutlet weak var recipientAddressTextField: UITextField!
    
    @IBOutlet weak var cityPickerView: UIPickerView!
    @IBOutlet weak var districtPickerView: UIPickerView!
    
    @IBAction func updateRecipientInfo(_ sender: UIButton) {
        guard let name = recipientNameTextField.text, let phoneNumber = recipientsPhoneTextField.text, let city = recipientCityTextField.text, let district = recipientDistrictTextField.text, let address = recipientAddressTextField.text else {return}
        let phoneInfo = PhoneInfo(phoneNumber: phoneNumber)
        let addressInfo = AddressInfo(postCode: currentPostCode, city: city, district: district, others: address)
        
        if user?.recipientInfo?.recipient_id == nil {
            
            APIrequest.shared.postRecipients(withToken: user.token, byName: name, withPhoneInfo: phoneInfo, withAddressInfo: addressInfo) { (APIresponse) in
                if APIresponse.result {
                    APIrequest.shared.getRecipient(withToken: self.user.token, result: { (responseRecipient) in
                        self.user.recipientInfo = responseRecipient.response.first
                        self.user.save()
                    })
                }
            }
        } else {
            let id = Int((user?.recipientInfo?.recipient_id)!)
            APIrequest.shared.patchRecipients(withToken: user.token, byName: name, withPhoneInfo: phoneInfo, withAddressInfo: addressInfo, withRecipientID: id) { (APIresponse) in
                if APIresponse.result {
                    self.user.recipientInfo = RecipientInfo.init(recipient_id: id, name: name, phone: phoneInfo, address: addressInfo)
                    self.user.save()
                }
            }
        }
    }
    
    
    @IBAction func showPayments(_ sender: UIButton) {
        APIrequest.shared.getOrders(withToken: user.token) { (responseOrder) in
            if responseOrder.result {
                self.orders = responseOrder.response
                self.performSegue(withIdentifier: "showPayment", sender: sender)
            }
        }
    }
    
    
    @IBAction func showShipments(_ sender: UIButton) {
        APIrequest.shared.getSellerOrders(withToken: user.token) { (responseOrder) in
            if responseOrder.result {
                self.orders = responseOrder.response
                self.performSegue(withIdentifier: "showShipment", sender: sender)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPayment":
            if let destinationViewController = segue.destination as? BuyerPaymentViewController {
                destinationViewController.user = self.user
                destinationViewController.orders = self.orders
            }
        case "showShipment":
            if let destinationViewController = segue.destination as? SellerShipmentViewController {
                destinationViewController.user = self.user
                destinationViewController.orders = self.orders
            }
        default:
            return
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityPickerView.dataSource = self
        cityPickerView.delegate = self
        districtPickerView.dataSource = self
        districtPickerView.delegate = self
    }
}

extension UserEditInfoViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let rows = pickerView.tag == 0 ? cities.count : districts.count
        return rows
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.tag == 0 {
            recipientCityTextField.text = cities[row]
            districts = postCodeInfos.filter({$0.City == cities[row]}).map({$0.Area})
            postCodes = postCodeInfos.filter({$0.City == cities[row]}).map({$0.ZipCode})
            districtPickerView.reloadAllComponents()
        } else {
            recipientDistrictTextField.text = districts[row]
            currentPostCode = postCodes[row]
            print(currentPostCode)
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return cities[row]
        } else {
            return districts[row]
        }
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}
