//
//  RoundedButton.swift
//  CastrApp
//
//  Created by Antoine on 07/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

@IBDesignable
open class RoundedButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 6
        
    }
    
    @IBInspectable
    public var imageTintColor: UIColor = UIColor.white {
        didSet {
            self.imageView?.tintColor = self.imageTintColor
        }
    }
    
    open override var isEnabled: Bool{
        didSet{
            if self.isEnabled {
                self.layer.opacity = 1
            }
                
            else {
                self.layer.opacity = 0.2
            }
        }
    }

}
