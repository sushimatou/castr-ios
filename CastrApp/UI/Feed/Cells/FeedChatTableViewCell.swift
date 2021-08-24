//
//  FeedMessageTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 04/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import Hex

class FeedChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var chat : ChatDto? {
        
        didSet{
            
            self.messageLabel.isHidden = chat!.lastMsgId == nil
            self.usernameLabel.text = chat!.name
            self.usernameLabel.textColor = UIColor(hex: ColorGeneratorHelper
                .getColorwithId(id: chat!.color))
            self.userImageView.backgroundColor = UIColor(hex: ColorGeneratorHelper
                .getColorwithId(id: chat!.color))
            if chat!.lastMsg != nil {
                switch chat!.lastMsg?.type {
                    
                case .text(let text)?:
                    self.messageLabel.text = text
                case .media(_, _, let text)?:
                    self.messageLabel.text = text
                default:
                    break
                    
                }
            }
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
