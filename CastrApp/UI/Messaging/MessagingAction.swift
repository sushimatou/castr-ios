//
//  ChatroomAction.swift
//  CastrApp
//
//  Created by Antoine on 19/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

enum MessagingAction {
    
    case undefined
    case startLoadMore
    case setFavoriteState(favorite: Bool)
    case setMediaAttachment(media: UIImage?)
    case updateLoves(messageId: String, loveAmount: Int)
    case showError(CastrError)
    
    // Messaging Actions
    
    case receiveMsg(message: MessageDto)
    case sendMsg(message: UserMessageDto, localId: String)
    case load(messages: [MessageDto], infos: MessagingInfos)
    case loadMoreMsg(messages: [MessageDto])
    case deletedMessage(messageId: String, userId: String, deletedAt: Int)
    case setReported(reported: Bool?)
    case setBlocked(blocked: Bool?)
    case setUnblocked(unblocked: Bool?)
    
    // Profile
    
    case loadProfile(_: UserDTO)
    
}

enum MagicWord {
    
    case joke
    case quote
    case feedback
    case quoteUser
    case none
    
}
