//
//  BuyerPaymentTableViewCell.swift
//  WannaBuy
//
//  Created by alien on 2019/3/24.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class BuyerPaymentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemTotalAmountLabel: UILabel!
    func layoutViews(withName name: String, withPrice totalAmount: String) {
        self.itemNameLabel.text = name
        self.itemTotalAmountLabel.text = totalAmount
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
