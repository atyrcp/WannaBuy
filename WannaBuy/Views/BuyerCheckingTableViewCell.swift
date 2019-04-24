//
//  BuyerCheckingTableViewCell.swift
//  WannaBuy
//
//  Created by alien on 2019/3/21.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class BuyerCheckingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    
    func layoutViews(withName name: String, withQuantity quantity: String, withPrice price: String) {
        itemNameLabel.text = name
        itemQuantityLabel.text = quantity
        itemPriceLabel.text = price
    }
        
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
