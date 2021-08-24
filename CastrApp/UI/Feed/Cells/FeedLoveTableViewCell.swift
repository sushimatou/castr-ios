//
//  FeedLoveTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import SDWebImage

class FeedLoveTableViewCell: UITableViewCell {
  
  @IBOutlet weak var messageView: RoundedMessageView!
  @IBOutlet weak var loveLimitCountLabel: UILabel!
  @IBOutlet weak var chatroomNameLabel: UILabel!
  @IBOutlet weak var chatroomImageView: UIImageView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var lovesCountLabel: UILabel!
  @IBOutlet weak var loveIconImageView: UIImageView!
    
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  var notification: NotificationDto! {
    
    didSet {
      
      self.chatroomNameLabel.text = notification.chatroom.name
      self.chatroomNameLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.chatroom.color))
      
      self.chatroomImageView.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.byColor))
      if let picture = notification.byPicture{
        self.chatroomImageView
          .sd_setImage(with: URL(string: picture), completed: nil)
        self.chatroomImageView.clipsToBounds = true
      }
      
      if let message = notification.message {
        
        self.loveLimitCountLabel.text = String(notification.threshold!)
        self.lovesCountLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: message.color))
        self.lovesCountLabel.text = String(message.love)
        self.loveIconImageView.tintColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: message.color))
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
          break // NOOP
        }
        
      }
    }
  }
}
