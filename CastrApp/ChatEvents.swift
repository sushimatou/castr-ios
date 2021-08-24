//
//  ChatEvents.swift
//  CastrApp
//
//  Created by Antoine on 13/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum ChatEvents {
    
    case load(messages: [MessageDto], infos: MessagingInfos)
    
    case messageSent(message: MessageDto)
    case messageLoved(messageId: String, loveAmount: Int, loveCount: Int)
    case messageDeleted(messageId: String, userId: String, deletedAt: Int)
    
    case chatroomUpdated(updates: [String:Any])
    case chatroomDeleted

    case leaved
    
}
