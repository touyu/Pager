//
//  PinterestMenuViewCell.swift
//  imo_ios
//
//  Created by Yuto Akiba on 2019/07/13.
//  Copyright © 2019 Yuto Akiba. All rights reserved.
//

import UIKit

final class PinterestMenuViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }

}
