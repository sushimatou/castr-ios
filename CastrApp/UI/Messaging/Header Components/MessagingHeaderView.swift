//
//  File.swift
//  CastrApp
//
//  Created by Antoine on 15/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

class MessagingHeaderView : UIView {
  
  // MARK : - IBOutlets
  
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var roomImageView: CircularImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  var infos: MessagingInfos! {
    
    didSet {
      
      switch infos{
        
      case .chat(let chatInfos)?:
        
        let color = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: chatInfos.color))
        self.welcomeLabel.text = "C'est le début de votre conversation avec"
        self.descriptionLabel.text = "Commencez par dire bonjour !"
        self.roomImageView.clipsToBounds = true
        self.roomImageView.backgroundColor = color
        self.titleLabel.text = chatInfos.name
        self.titleLabel.textColor = color
        
        if let picture = chatInfos.picture {
          self.roomImageView.sd_setImage(
            with: URL(string: picture),
            completed: nil)
        }
        
      case .chatroom(let chatroomInfos)?:
        
        let color = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: chatroomInfos.color))
        self.roomImageView.backgroundColor = color
        self.titleLabel.text = chatroomInfos.name
        self.titleLabel.textColor = color
        self.roomImageView.sd_setImage(
          with: URL(string: chatroomInfos.picture),
          completed: nil)
        self.roomImageView.clipsToBounds = true
        
        if chatroomInfos.description != "" {
          self.descriptionLabel.text = chatroomInfos.description
        } else {
          self.descriptionLabel.text = "Pas de description"
        }
      case .none:
        break
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
}
