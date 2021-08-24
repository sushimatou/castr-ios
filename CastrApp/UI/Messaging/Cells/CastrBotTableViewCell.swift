//
//  CastrBotTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 06/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class CastrBotTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
    var type: BotMessageType! {
        didSet {
            switch type! {
                
            case .text(let text):
                self.messageLabel.text = text
            case .set:
                break
            case .invite:
                break
            }
    }
    }
}
