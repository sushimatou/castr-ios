//
//  CustomNavigationBar.swift
//  CastrApp
//
//  Created by Antoine on 04/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

class CustomNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
        backItem?.title = nil
        super.layoutSubviews()
    }
    
}
