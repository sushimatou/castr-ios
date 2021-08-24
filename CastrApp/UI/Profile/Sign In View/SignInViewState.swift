//
//  SignInViewState.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum SignInViewState {
  case loading
  case empty
  case editing(mail: FieldState, pwd: FieldState)
  case connected
  case error(_: CastrError)
}
