//
//  Config.swift
//  CastrApp
//
//  Created by Antoine on 04/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct Config {
  
  static let endPoint = Bundle.main.infoDictionary!["API_BASE_URL_ENDPOINT"] as! String
  
  #if PREPROD
  static let apiEndPoint = "http://\(endPoint)/api/v1"
  static let wsEndPoint = "ws://\(endPoint)"
  
  #else
  static let apiEndPoint = "https://\(endPoint)/api/v1"
  static let wsEndPoint = "wss://\(endPoint)"
  #endif
  
}
