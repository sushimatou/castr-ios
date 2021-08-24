//
//  ProfileDTO.swift
//  CastrApp
//
//  Created by Antoine on 25/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UserDTO {
  
  var color: Int
  var isRegistered: Bool
  var name: String
  var picture: String?
  var id: String
  var loves: Int
  var messages: Int
  var blackList = [String]()
  
  init() {
    self.color = 0
    self.isRegistered = false
    self.name = ""
    self.id = ""
    self.loves = 0
    self.messages = 0
  }
  
  init(json: JSON){
    self.id = json["user_id"].stringValue
    self.name = json["profile"]["name"].stringValue
    self.color = json["profile"]["color"].intValue
    self.picture = json["profile"]["picture"]["uri"].string
    self.loves = json["profile"]["stats"]["love"].intValue
    self.messages = json["profile"]["stats"]["messages"].intValue
    self.isRegistered = json["profile"]["is_registered"].boolValue
  }
}
