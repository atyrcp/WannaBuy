//
//  SellerCheckingTableViewCell.swift
//  WannaBuy
//
//  Created by alien on 2019/3/23.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class SellerCheckingTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityLabel: UILabel!
    
    func layoutViews(withName name: String, withQuantity quantity: String) {
        self.itemNameLabel.text = name
        self.itemQuantityLabel.text = quantity
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
