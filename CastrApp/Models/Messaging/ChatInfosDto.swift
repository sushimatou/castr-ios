//
//  ChatInfosDto.swift
//  CastrApp
//
//  Created by Antoine on 15/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct ChatInfosDto {
    
    var color: Int
    var name: String
    var picture: String?
    
    init(jsonChat: JSON){
        self.color = jsonChat["color"].intValue
        self.name = jsonChat["name"].stringValue
        self.picture =  jsonChat["picture"]["uri"].stringValue
    }
    
    
}
