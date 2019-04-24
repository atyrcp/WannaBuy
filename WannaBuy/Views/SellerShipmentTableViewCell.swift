//
//  SellerShipmentTableViewCell.swift
//  WannaBuy
//
//  Created by alien on 2019/3/23.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class SellerShipmentTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var recipientPhoneLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!
    
    func latoutViews(withName itemName: String, withQuantity quantity: String, withRecipient recipientName: String, withPhone phone: String, withAddress address: String) {
        self.itemNameLabel.text = itemName
        self.itemQuantityLabel.text = quantity
        self.recipientNameLabel.text = recipientName
        self.recipientPhoneLabel.text = phone
        self.recipientAddressLabel.text = address
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
