//
//  SignUpState.swift
//  CastrApp
//
//  Created by Antoine on 05/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct SignUpState {
  
  var isEnabled: Bool
  var mail: FieldState? = .pristine
  var pwd: FieldState? = .pristine
  var username: FieldState? = .pristine
  
  init(isEnabled: Bool){
    self.isEnabled = isEnabled
  }
  
}
