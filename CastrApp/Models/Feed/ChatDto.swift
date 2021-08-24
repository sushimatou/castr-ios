//
//  ChatDto.swift
//  CastrApp
//
//  Created by Antoine on 18/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ChatDto {
  
  var id: String
  var lastUpdate: Int
  var color: Int
  var name: String
  var pictureUrl: String?
  var lastMsg: UserMessageDto?
  var lastSeenId: String?
  var lastMsgId: String?
  var isSeen: Bool?
  
  init(json: JSON){
    self.id = json["id"].stringValue
    self.lastUpdate = json["lastUpdate"].intValue
    self.color = json["with"]["color"].intValue
    self.name = json["with"]["name"].stringValue
    self.pictureUrl = json["with"]["picture"].string
    self.lastSeenId = json["chat"]["lastSeedId"].string
    self.lastMsgId = json["chat"]["lastMsgId"].string
    if json["chat"]["lastMsg"].exists() {
      self.lastMsg = UserMessageDto(json: json["chat"]["lastMsg"])
    }
  }
  
  init(id: String,
       lastUpdate: Int,
       color: Int,
       name: String,
       pictureUrl: String?){
    self.id = id
    self.lastUpdate = lastUpdate
    self.color = color
    self.name = name
    self.pictureUrl = pictureUrl
  }
}
