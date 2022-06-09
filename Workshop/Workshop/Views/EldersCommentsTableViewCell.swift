//
//  EldersCommentsTableViewCell.swift
//  Workshop
//
//  Created by Martina on 2/22/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit

class EldersCommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        comment.isEditable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
