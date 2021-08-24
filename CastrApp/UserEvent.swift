//
//  UserEvents.swift
//  CastrApp
//
//  Created by Antoine on 30/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum UserEvent {
    
    case profileLoaded(user: UserDTO)
    case statsUpdated(stats: (loves: Int?, messages: Int?))
    case profileUpdated(name: String?, color: Int?, isRegistered: Bool?, picture: String?)
    case addUserToBlackList(blacklistedUserId: String)
    case removeUserFromBlacklist(blacklistedUserId: String)
    case loadBlacklist(blacklist: [String])
}
