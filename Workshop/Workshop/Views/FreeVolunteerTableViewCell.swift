
//
//  FreeVolunteerTableViewCell.swift
//  Workshop
//
//  Created by Martina on 2/24/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit

class FreeVolunteerTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
