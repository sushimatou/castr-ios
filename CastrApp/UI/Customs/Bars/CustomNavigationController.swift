//
//  CustomNavBar.swift
//  CastrApp
//
//  Created by Antoine on 02/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
  
  convenience init() {
    self.init(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
  }
  
}

