//
//  ChatroomDTO.swift
//  CastrApp
//
//  Created by Antoine on 11/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum Role: String {
  
  case admin = "admin"
  case moderator = "moderator"
  case member = "member"
  case spectator = "spectator"
  case banned = "banned"
  
}

public struct ChatroomDTO {
  
  var id: String
  var createdAt: Int
  var rank: Double
  var name: String
  var picture: String
  var date: Int
  var deleted: Int
  var description: String?
  var color: Int
  var creatorId: String
  var loveCount: Int
  var membersCount: Int
  var messagesCount: Int
  var isPublic: Bool
  var isFavorite: Bool
  var role: Role?

  init(jsonChatroom: JSON) {
    if jsonChatroom["chatroom"]["id"].exists() {
      self.id = jsonChatroom["chatroom"]["id"].stringValue
    } else {
      self.id = jsonChatroom["chatroom_id"].stringValue
    }
    self.createdAt = jsonChatroom["chatroom"]["created"].intValue
    self.rank = jsonChatroom["rank"].doubleValue
    self.color = jsonChatroom["chatroom"]["color"].intValue
    self.date = jsonChatroom["chatroom"]["created"].intValue
    self.creatorId = jsonChatroom["chatroom"]["creator"].stringValue
    self.deleted = jsonChatroom["chatroom"]["deleted"].intValue
    self.description = jsonChatroom["chatroom"]["description"].string
    self.name = jsonChatroom["chatroom"]["name"].stringValue
    self.picture = jsonChatroom["chatroom"]["picture"]["uri"].stringValue
    self.loveCount = jsonChatroom["chatroom"]["stats"]["love"].intValue
    self.messagesCount = jsonChatroom["chatroom"]["stats"]["messages"].intValue
    self.membersCount = jsonChatroom["chatroom"]["stats"]["members"].intValue
    self.isPublic = jsonChatroom["chatroom"]["public"].boolValue
    self.isFavorite = jsonChatroom["is_favorite"].boolValue
    
    if jsonChatroom["role"].exists() {
      self.role = Role(rawValue: jsonChatroom["role"].stringValue)!
    }
  }
}
