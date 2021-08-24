//
//  FavoriteDto.swift
//  CastrApp
//
//  Created by Antoine on 18/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

struct FavoriteDto {
  
  enum FavType {
    case favorite
    case opened
  }
  
  var id: String
  var lastUpdate: Int
  var favType: FavType
  
  var color: Int
  var description: String
  var name: String
  var pictureUrl: String?
  
  
  init(json: JSON){
    self.id = json["id"].stringValue
    self.lastUpdate = json["lastUpdate"].intValue
    
    if json["channel"]["update"] == "opened" {
      self.favType = .opened
    }
    else {
      self.favType = .favorite
    }
    
    self.color = json["chatroom"]["color"].intValue
    self.description = json["chatroom"]["description"].stringValue
    self.name = json["chatroom"]["name"].stringValue
    self.pictureUrl = json["chatroom"]["uri"].string
  }
  
  init(id: String, lastUpdate: Int, favType: FavType, color: Int, description: String, name: String) {
    self.id = id
    self.lastUpdate = lastUpdate
    self.favType = favType
    self.color = color
    self.description = description
    self.name = name
  }

}
