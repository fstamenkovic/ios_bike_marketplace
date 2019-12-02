//
//  CustomCellTableViewCell.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/20/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet weak var title_label: UILabel!
        
    @IBOutlet weak var price_label: UILabel!
    
    @IBOutlet weak var color_label: UILabel!
    
    @IBOutlet weak var category_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
