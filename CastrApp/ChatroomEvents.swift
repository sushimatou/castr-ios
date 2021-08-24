//
//  ChatroomEvents.swift
//  CastrApp
//
//  Created by Antoine on 29/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum ChatroomEvents {
    
    case load(messages: [MessageDto], infos: MessagingInfos)
    case loadMoreMsg(messages: [MessageDto])
    
    case messageSent(message: MessageDto)
    case messageLoved(messageId: String, loveAmount: Int, loveCount: Int)
    case messageDeleted(messageId: String, userId: String, deletedAt: Int)
    
    case chatroomUpdated(updates: [String:Any])
    case chatroomDeleted
    
    case userWarned(fromId: String, memberId: String, reason: String)
    case userBanned(fromId: String, memberId: String, reason: String)
    case userRoleUpdated(fromId: String, memberId: String, role: String)
    
    case error(CastrError)
    case leaved
    
}
