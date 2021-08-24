//
//  SearchBar.swift
//  CastrApp
//
//  Created by Antoine on 03/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

class SearchBar : UISearchBar {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.keyboardAppearance = .dark
        self.isTranslucent = false
        self.barTintColor = UIColor.castrGray
        self.textField?.backgroundColor = UIColor.castrLightGray
        self.textField?.textColor = UIColor.castrBlue
        self.textField?.font = UIFont(name: "Roboto-Regular", size: 17)
        self.textField?.attributedPlaceholder = NSAttributedString(string: "Chercher une chatroom", attributes:
            [ NSForegroundColorAttributeName: UIColor.gray,
              NSFontAttributeName : UIFont(name: "Roboto-Regular", size: 17)!
            ])
        self.tintColor = UIColor.castrBlue
    }
    
}
