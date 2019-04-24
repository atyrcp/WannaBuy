//
//  SellerShipmentViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/3/19.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class SellerShipmentViewController: UIViewController {

    var user: User!
    var orders: [Order]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension SellerShipmentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "sellerShipmentCell", for: indexPath) as? SellerShipmentTableViewCell, let order =  orders?[indexPath.row] {
            let itemName = order.name
            let itemQuantity = String(order.quantity)
            let recipientName = order.recipient
            let phone = order.phone_number
            let address = order.post_code + order.city + order.district + order.others
            
            cell.latoutViews(withName: itemName, withQuantity: itemQuantity, withRecipient: recipientName, withPhone: phone, withAddress: address)
            return cell
        }
        return UITableViewCell()
    }
    
    
}
