//
//  SignUpUsernameAction.swift
//  CastrApp
//
//  Created by Antoine on 06/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum SignUpUsernameAction {
  case setUsernameTextFieldState(state: FieldState)
  case signUpUser
  case signUpError(CastrError)
}
