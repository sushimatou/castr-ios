//
//  CircularImageView.swift
//  CastrApp
//
//  Created by Antoine on 07/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

open class CircularImageView: UIImageView {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = (self.bounds.width)/2;
        self.clipsToBounds = false
    }
    
}
