//
//  DiscoveryTableViewCell.swift
//  CastrApp
//
//  Created by Castr on 10/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import Hex
import SDWebImage

class DiscoveryTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var membersIcon: UIImageView!
    @IBOutlet weak var messagesIcon: UIImageView!
    @IBOutlet weak var bgCell: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var messagesCount: UILabel!
    @IBOutlet weak var membersCount: UILabel!
    @IBOutlet weak var chatroomPic: UIImageView!
    
    // MARK: - Properties
    
    var path = ""

    func setChatroom (chatroom: ChatroomDTO){
        
        titleLabel.text = chatroom.name
        membersCount.text = "\(chatroom.membersCount)"
        messagesCount.text = "\(chatroom.messagesCount)"
        descriptionLabel.text = chatroom.description
        titleLabel.textColor = UIColor(hex: ColorGeneratorHelper
                    .getColorwithId(id: chatroom.color))
        chatroomPic.backgroundColor = UIColor(hex: ColorGeneratorHelper
                    .getColorwithId(id: chatroom.color))
        
        chatroomPic.sd_setImage(with: URL(string: chatroom.picture), placeholderImage: nil, completed: { (image, error, cache, url) in
            self.chatroomPic.layer.cornerRadius = self.chatroomPic.frame.size.width/2
            self.chatroomPic.layer.masksToBounds = true
        })
        
        bgCell.layer.cornerRadius = 5
        bgCell.layer.masksToBounds = true
        bgCell.layer.shadowColor = UIColor.black.cgColor
        bgCell.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        bgCell.layer.shadowOpacity = 0.2
        bgCell.layer.shadowPath = UIBezierPath(rect: bgCell.bounds).cgPath
        self.contentView.sizeToFit()
        chatroomPic.layer.cornerRadius = chatroomPic.frame.size.width/2
        messagesIcon.tintColor = UIColor(hex: "78787b")
        membersIcon.tintColor = UIColor(hex: "78787b")
        
    }
    
    override func prepareForReuse() {
        chatroomPic.image = nil
    }
}
