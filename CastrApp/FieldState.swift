//
//  FieldState.swift
//  CastrApp
//
//  Created by Antoine on 05/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum FieldState {
  case valid
  case error(error: String)
  case loading
  case pristine
}
