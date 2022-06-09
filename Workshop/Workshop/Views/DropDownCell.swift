//
//  DropDownCell.swift
//  Workshop
//
//  Created by Martina on 2/12/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit
import DropDown

class MyCell: DropDownCell {
    
    @IBOutlet var myImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
