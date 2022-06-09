//
//  VolunteerTableViewCell.swift
//  Workshop
//
//  Created by Martina on 12/18/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit

class VolunteerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var elderName: UILabel!
    @IBOutlet weak var elderRating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
