//
//  NotificationDTO.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct NotificationDto {
  
  public enum NotificationType: String {
    
    case invite = "invite"
    case warning = "warn"
    case ban = "ban"
    case roleUpdate = "role_update"
    case love = "message_love"
    case quote = "quoted"
  }
  
  var id: String
  var chatroom: ChatroomDTO
  var message: UserMessageDto?
  var reason: String?
  var threshold: Int?
  var createdAt: Int
  var lastUpdate: Int
  
  // Todo use User DTO as user json serializer
  var byColor: Int
  var byName: String
  var byId: String
  var byPicture: String?
  // ------------------------------------------
  
  var type: NotificationType
  
  init(json: JSON) {
    self.lastUpdate = json["lastUpdate"].intValue
    self.id = json["id"].stringValue
    self.createdAt = json["at"].intValue
    self.chatroom = ChatroomDTO(jsonChatroom: json["data"])
    self.reason = json["data"]["reason"].string
    self.type = NotificationType(rawValue: json["type"].stringValue)!
    self.byColor = json["data"]["by"]["color"].intValue
    self.byName = json["data"]["by"]["name"].stringValue
    self.byId = json["data"]["by"]["name"].stringValue
    self.byPicture = json["data"]["by"]["picture"]["uri"].string
    self.message = UserMessageDto(json: json["data"]["message"])
    self.threshold = json["data"]["threshold"].int
  }
  
}
