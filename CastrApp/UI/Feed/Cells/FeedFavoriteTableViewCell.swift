//
//  FeedFavoriteTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 04/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import SDWebImage

class FeedFavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatroomNameLabel: UILabel!
    @IBOutlet weak var chatroomImageView: UIImageView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var selfMessagesCountLabel: UILabel!
    @IBOutlet weak var selfPicImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var favorite: FavoriteDto? {
        
        didSet {
            
            chatroomNameLabel.text = favorite!.name
            chatroomNameLabel.textColor = UIColor(hex: ColorGeneratorHelper
                .getColorwithId(id: favorite!.color))
            chatroomImageView.backgroundColor = UIColor(hex: ColorGeneratorHelper
                .getColorwithId(id: favorite!.color))
            
            if favorite!.pictureUrl != nil {
                self.chatroomImageView.sd_setImage(with: URL(string: favorite!.pictureUrl!), placeholderImage: nil, completed: { (image, error, cache, url) in
                    self.chatroomImageView.image = image
                    self.chatroomImageView.layer.cornerRadius = self.chatroomImageView.frame.size.width/2
                    self.chatroomImageView.layer.masksToBounds = true
                })
            }
            
        }
        
    }
    
    
    override func prepareForReuse() {
        chatroomImageView.image = nil
    }

}
