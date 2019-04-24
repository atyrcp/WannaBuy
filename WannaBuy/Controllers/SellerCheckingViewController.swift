//
//  SellerCheckingViewController.swift
//  WannaBuy
//
//  Created by alien on 2019/2/14.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class SellerCheckingViewController: UIViewController {
    
    var user: User!
    var orders: [Order]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension SellerCheckingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCheckcingCell", for: indexPath) as? SellerCheckingTableViewCell {
            let itemName = orders?[indexPath.row].name
            let itemQuantity = String((orders?[indexPath.row].quantity)!)
            cell.layoutViews(withName: itemName!, withQuantity: itemQuantity)
            return cell
        }
        return UITableViewCell()
    }
    
    
}
