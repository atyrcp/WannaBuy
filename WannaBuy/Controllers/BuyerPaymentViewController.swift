//
//  BuyerPaymentViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/3/24.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class BuyerPaymentViewController: UIViewController {
    
    var user: User!
    var orders: [Order]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BuyerPaymentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "buyerPaymentCell", for: indexPath) as? BuyerPaymentTableViewCell, let order =  orders?[indexPath.row] {
            let itemName = order.name
            let totalAmount = String(order.total_amount)
            
            cell.layoutViews(withName: itemName, withPrice: totalAmount)
            return cell
        }
        return UITableViewCell()
    }
    
    
}
