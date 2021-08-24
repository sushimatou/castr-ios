//
//  ChatroomAdminTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 28/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class ChatroomAdminTableViewCell: UITableViewCell {
    
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
    
  var user: UserDTO!{
    didSet{
      let color = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: user.color))
      self.usernameLabel.textColor = color
      self.usernameLabel.text = user.name
      self.userImageView.backgroundColor = color
      if let picture = user.picture{
        self.userImageView.sd_setImage(
        with: URL(string: picture),
        completed: nil)
      }
    }
  }
  
}
