//
//  MessageDto.swift
//  CastrApp
//
//  Created by Antoine on 09/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MessageDto {
    
    var id: String
    var createdAt: Date
    var type: MessageType
    
    init(json: JSON, type: MessageType){
        self.id = json["id"].stringValue
        self.createdAt = Date(timeIntervalSince1970: json["createdAt"].doubleValue / 1000)
        self.type = type
    }
    
    init(id: String, type: MessageType){
        self.id = id
        self.type = type
        self.createdAt = Date()
    }
    
    init(id: String, type: MessageType, createdAt: Double){
        self.id = id
        self.type = type
        self.createdAt = Date(timeIntervalSince1970: createdAt / 1000)
    }
    
}

public enum MessageType {
    case infoMessage(text:String)
    case botMessage(type: BotMessageType)
    case userMessage(message: UserMessageDto)
}

public enum BotMessageType {
    case text(_: String)
    case set
    case invite
}


