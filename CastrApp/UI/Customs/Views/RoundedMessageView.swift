//
//  RoundedMessageView.swift
//  CastrApp
//
//  Created by Antoine on 07/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

open class RoundedMessageView: UIView {
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layer.cornerRadius = 6
    self.layer.masksToBounds = false
    
  }
  
}
