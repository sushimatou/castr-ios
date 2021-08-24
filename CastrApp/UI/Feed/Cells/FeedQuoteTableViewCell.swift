//
//  FeedQuoteTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class FeedQuoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageView: RoundedMessageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var chatroomNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chatroomImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var notification: NotificationDto! {
        
        didSet {
            
            self.usernameLabel.text = notification.byName
            
            self.chatroomNameLabel.text = notification.chatroom.name
            if let message = notification.message {

                self.messageView.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: message.color))
                
                switch message.type {
                    
                case .text(let text):
                    self.messageLabel.text = text
                    
                case .media(_, _, _):
                    self.messageLabel.text = "Image envoyée"
                    
                case .joke(let joke):
                    self.messageLabel.text = joke
                    
                case .quote(let quote):
                    self.messageLabel.text = quote
                    
                case .deleted:
                    self.messageLabel.text = "Message supprimé"
                case .embed(_):
                  break
                  
                case .blocked:
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
