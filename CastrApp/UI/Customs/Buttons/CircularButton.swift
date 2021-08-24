//
//  CircularButton.swift
//  CastrApp
//
//  Created by Antoine on 07/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit


open class CircularButton: UIButton {

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = (self.bounds.width)/2
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.init(width: 5, height: 5)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.2
    }
}
