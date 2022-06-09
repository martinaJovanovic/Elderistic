//
//  VolunteersTableViewCell.swift
//  Workshop
//
//  Created by Martina on 2/18/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit

class VolunteersTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var number: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
