//
//  MessagingHeaderSectionView.swift
//  CastrApp
//
//  Created by Antoine on 08/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class MessagingHeaderSectionView: UIView {

    @IBOutlet weak var dateLabel: UILabel!
    
    var dateStr: String! {
        didSet{
          dateLabel.text = dateStr
        }
    }

}
