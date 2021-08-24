//
//  FeedInviteTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import SDWebImage

class FeedInviteTableViewCell: UITableViewCell {
  
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var picImageView: UIImageView!
  @IBOutlet weak var chatroomNameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var messageCountLabel: UILabel!
  @IBOutlet weak var membersCountLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  var notification: NotificationDto! {
    
    didSet {
        
      self.usernameLabel.text = notification.byName
      self.usernameLabel.tintColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.byColor))
        
      self.chatroomNameLabel.text = notification.chatroom.name
      self.chatroomNameLabel.tintColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.chatroom.color))
        
      self.picImageView.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.chatroom.color))
    
      self.picImageView.sd_setImage(with: URL(string: notification.chatroom.picture),
                                      completed: nil)
        
      self.descriptionLabel.text = notification.chatroom.description
      self.messageCountLabel.text = String(notification.chatroom.messagesCount)
      self.membersCountLabel.text = String(notification.chatroom.membersCount)
    }
    
  }
  
}
