//
//  FeedBanTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 04/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class FeedBanTableViewCell: UITableViewCell {
  
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var banReasonLabel: UILabel!
  @IBOutlet weak var chatroomNameLabel: UILabel!
  @IBOutlet weak var chatroomImageView: UIImageView!
  
  var notification: NotificationDto! {
    
    didSet {
      
      self.chatroomNameLabel.text = notification.chatroom.name
      self.chatroomNameLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.chatroom.color))
      
      self.chatroomImageView.sd_setImage(with: URL(string: notification.chatroom.picture), completed: nil)
      self.chatroomImageView.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.chatroom.color))
      self.chatroomImageView.clipsToBounds = true
      
      self.usernameLabel.text = notification.byName
      self.usernameLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: notification.byColor))
      self.banReasonLabel.text = notification.reason
      
    }
    
  }
}
