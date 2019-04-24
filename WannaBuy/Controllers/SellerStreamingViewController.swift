//
//  SellerStreamingViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/2/14.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class SellerStreamingViewController: UIViewController {

    var timer: Timer?
    var user: User?
    var sellingList = [Item]()
    var currentItemIndex = 0
    
    @IBOutlet weak var itemImageView: UIImageView! {
        didSet {
            if sellingList.count != 0 {
                let imageData = sellingList[0].images
                itemImageView.image = UIImage(data: imageData)
            } else {
                itemImageView.image = #imageLiteral(resourceName: "noImage")
            }
            
        }
    }
    @IBOutlet weak var itemNameLabel: UILabel! {
        didSet {
            if sellingList.count != 0 {
                itemNameLabel.text = sellingList[0].name
            } else {
                itemNameLabel.text = "item"
            }
        }
    }
    @IBOutlet weak var itemSoldLabel: UILabel!
    @IBOutlet weak var itemLeftLabel: UILabel!
    @IBOutlet weak var startSellingItemButton: UIButton!
    @IBOutlet weak var endSellingItemButton: UIButton!
    @IBOutlet weak var stopStreamingButton: UIButton!
    
    
    
    @IBAction func showLastItem(_ sender: UIButton) {
        
        if sellingList.count == 0 {
            return
        }
        
        if currentItemIndex == 0 {
            return
        } else {
            currentItemIndex -= 1
            let imageData = sellingList[currentItemIndex].images
            itemImageView.image = UIImage(data: imageData)
        }
    }
    
    @IBAction func showNextItem(_ sender: UIButton) {
        
        if sellingList.count == 0 {
            return
        }
        
        if currentItemIndex == sellingList.count - 1 {
            return
        } else {
            currentItemIndex += 1
            let imageData = sellingList[currentItemIndex].images
            itemImageView.image = UIImage(data: imageData)
        }
    }
    
    @IBAction func startSellingItem(_ sender: UIButton) {
        let itemId = sellingList[currentItemIndex].id
        APIrequest.shared.postStreamingItems(withToken: (user?.token)!, withItemId: itemId) { (APIresponse) in
            if APIresponse.result {
                self.startSellingItemButton.isEnabled = false
                self.endSellingItemButton.isEnabled = true
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.checkingItemSellingState), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func checkingItemSellingState() {
        APIrequest.shared.getStreamingItems(withToken: (user?.token)!) { (responseItem) in
            if responseItem.result {
                
                let soldItemQuantity = String((responseItem.response?.sold_quantity)!)
                let remainingItemQuantity = String((responseItem.response?.remaining_quantity)!)
                DispatchQueue.main.async {
                    self.itemSoldLabel.text = soldItemQuantity
                    self.itemLeftLabel.text = remainingItemQuantity
                }
                
            }
        }
    }
    
    @IBAction func endSellingItem(_ sender: UIButton) {
        timer = nil
        startSellingItemButton.isEnabled = true
        itemLeftLabel.text = "0"
        itemSoldLabel.text = "0"
        
    }
    
    @IBAction func stopStreaming(_ sender: UIButton) {
        startSellingItemButton.isEnabled = false
        endSellingItemButton.isEnabled = false
        APIrequest.shared.putChannel(withToken: (user?.token)!) { (APIresponse) in
            if APIresponse.result {
                APIrequest.shared.getSellerOrdersWithChannel(withToken: (self.user?.token)!, withChannelID: (self.user?.channelInfo?.channel_id)!, result: { (responseOrders) in
                    if responseOrders.result {
                        let orders = responseOrders.response
                        
                        guard let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SellerCheckingViewController") as? SellerCheckingViewController else {return}
                        
                        destinationViewController.user = self.user
                        destinationViewController.orders = orders
                        self.present(destinationViewController, animated: true)
                    }
                    
                    guard let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SellerCheckingViewController") as? SellerCheckingViewController else {return}
                    
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
