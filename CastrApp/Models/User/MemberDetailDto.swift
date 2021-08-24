//
//  MemberDetailDto.swift
//  CastrApp
//
//  Created by Antoine on 27/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct MemberDetailDto {
    
    var isOnline: Bool
    var name: String
    var color: Int
    var pictureUrl: String?
    var role: Role
    var love: Int
    var messages: Int
    
    init(json: JSON) {
        
        self.isOnline = json["member"]["online"].boolValue
        self.name = json["profile"]["name"].stringValue
        self.color = json["profile"]["name"].intValue
        self.pictureUrl =  json["profile"]["picture"]["uri"].string
        self.love = json["stats"]["love"].intValue
        self.messages = json["stats"]["messages"].intValue
        
        if json["role"].exists() && !json["role"].isEmpty {
            self.role = Role(rawValue: json["role"].stringValue)!
        }
        else {
            self.role = Role.member
        }
    }
    
}
