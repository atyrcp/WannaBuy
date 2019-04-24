//
//  BuyerEnteringViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/2/14.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit
import WebKit

class BuyerEnteringViewController: UIViewController {
    
    var user: User!
    var timer: Timer?
    var currentItemID: Int?
    var currentItemName = "" {
        didSet {
            itemNameLabel.text = currentItemName
        }
    }
    var currentItemPrice = 0 {
        didSet {
            itemPriceLabel.text = String(currentItemPrice)
        }
    }
    var currentItemRemaining = 0 {
        didSet {
            itemRemainingQuantityLabel.text = String(currentItemRemaining)
        }
    }
    
    @IBOutlet weak var channelTokenTextField: UITextField!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemRemainingQuantityLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UITextField!
    @IBOutlet weak var orderResultLabel: UILabel!
    @IBOutlet weak var streamingWebView: WKWebView!
    
    
    @IBAction func joinChannel(_ sender: UIButton) {
        guard let channelToken = channelTokenTextField.text else {return}
        APIrequest.shared.patchUserChannelId(withToken: user.token, withChannelToken: channelToken) { (APIresponse) in
            if APIresponse.result {
                let source = APIresponse.response
                guard let url = URL(string: source) else {return}
                self.streamingWebView.load(URLRequest(url: url))
                self.streamingWebView.reload()
                
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.getStreamingItems), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func getStreamingItems() {
        APIrequest.shared.getStreamingItems(withToken: user.token) { (responseItem) in
            self.currentItemID = responseItem.response?.item_id
            self.currentItemName = (responseItem.response?.name)!
            self.currentItemPrice = (responseItem.response?.unit_price)!
            self.currentItemRemaining = (responseItem.response?.remaining_quantity)!
        }
    }
    @IBAction func placeAnOrder(_ sender: UIButton) {
        guard let id = currentItemID, let recipientID = user.recipientInfo?.recipient_id, let number = Int(orderNumberLabel.text!) else {return}
        APIrequest.shared.postOrders(withToken: user.token, withItemId: id, withRecipientId: recipientID, withNumbers: number) { (APIresponse) in
            if APIresponse.result {
                self.orderResultLabel.text = "thanks for your purchasing"
            }
        }
    }
    
    @IBAction func leaveChannel(_ sender: UIButton) {
        APIrequest.shared.putChannel(withToken: user.token) { (APIresponse) in
            if APIresponse.result {
                APIrequest.shared.getLatestChannelOrders(withToken: self.user.token, result: { (responseOrders) in
                    if responseOrders.result {
                        let orders = responseOrders.response
                        
                        guard let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyerCheckingViewController") as? BuyerCheckingViewController else {return}
                        
                        destinationViewController.user = self.user
                        destinationViewController.orders = orders
                        self.present(destinationViewController, animated: true)
                    }
                    
                    guard let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyerCheckingViewController") as? BuyerCheckingViewController else {return}
                    
                    destinationViewController.user = self.user
                    self.present(destinationViewController, animated: true)
                })
            }
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
