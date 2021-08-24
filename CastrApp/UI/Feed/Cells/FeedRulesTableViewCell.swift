//
//  FeedRulesTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class FeedRulesTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var chatroomNameLabel: UILabel!
    @IBOutlet weak var ruleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
