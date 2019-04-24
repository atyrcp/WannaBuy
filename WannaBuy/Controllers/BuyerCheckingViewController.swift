//
//  BuyerCheckingViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/2/14.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class BuyerCheckingViewController: UIViewController {
    
    var user: User!
    var orders: [Order]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BuyerCheckingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "buyerCheckingCell", for: indexPath) as? BuyerCheckingTableViewCell {
            let itemName = orders?[indexPath.row].name
            let itemQuantity = String((orders?[indexPath.row].quantity)!)
            let itemPrice = String((orders?[indexPath.row].unit_price)!)
            cell.layoutViews(withName: itemName!, withQuantity: itemQuantity, withPrice: itemPrice)
            return cell
        }
        return UITableViewCell()
    }
    
    
}
