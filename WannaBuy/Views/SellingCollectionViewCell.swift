//
//  SellingCollectionViewCell.swift
//  WannaBuy
//
//  Created by alien on 2019/2/20.
//  Copyright © 2019 z. All rights reserved.
//

import UIKit

class SellingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    func figureImageOnCell(with item: Item) {
        itemImageView.image = UIImage(data: item.images)
    }
}
