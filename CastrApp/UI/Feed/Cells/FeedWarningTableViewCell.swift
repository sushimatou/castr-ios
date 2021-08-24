//
//  FeedWarningTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import SDWebImage

class FeedWarningTableViewCell: UITableViewCell {
  
  @IBOutlet weak var chatroomNameLabel: UILabel!
  @IBOutlet weak var reasonLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var chatroomImageView: UIImageView!
  
  var notification: NotificationDto! {
    
    didSet {
      self.chatroomNameLabel.text = notification.chatroom.name
      self.chatroomNameLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.chatroom.color))
      
      self.usernameLabel.text = notification.byName
      self.usernameLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.byColor))
      
      self.reasonLabel.text = notification.reason
      self.chatroomImageView.sd_setImage(with: URL(string: notification.chatroom.picture), completed: nil)
      self.chatroomImageView.clipsToBounds = true
      self.chatroomImageView.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.chatroom.color))
    }
  }
  
}
