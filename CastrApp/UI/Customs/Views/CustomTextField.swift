//
//  CustomTextField.swift
//  CastrApp
//
//  Created by Antoine on 04/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

open class CustomTextField : UITextField {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        font = UIFont(name: "Roboto-Regular", size: 17)
        textColor = UIColor.white
        tintColor = UIColor.white
        keyboardAppearance = .dark
        backgroundColor = UIColor.castrLightGray
        
        if placeholder != nil {
            let attributes = [
            NSForegroundColorAttributeName: UIColor.gray,
            NSFontAttributeName : UIFont(name: "Roboto-Regular", size: 17)!
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder!, attributes:attributes)
        }
    }
}
