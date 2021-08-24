//
//  SearchResultTableViewCell.swift
//  CastrApp
//
//  Created by Antoine on 27/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import SDWebImage
import Hex

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var chatroomImageView: UIImageView!
    @IBOutlet weak var chatroomNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var result: SearchResultsDto? {
        
        didSet{
            chatroomNameLabel.text = result!.name
            chatroomNameLabel.textColor = UIColor(hex: ColorGeneratorHelper
                .getColorwithId(id: result!.color))
            chatroomImageView.backgroundColor = UIColor(hex: ColorGeneratorHelper
                .getColorwithId(id: result!.color))
            
            if let picture = result?.picture {
                chatroomImageView.sd_setImage(with: URL(string: picture), completed: nil)
            }
            self.chatroomImageView.clipsToBounds = true
            
        }
        
    }

}
