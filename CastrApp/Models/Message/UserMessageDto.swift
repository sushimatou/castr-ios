//
//  Message.swift
//  CastrApp
//
//  Created by Antoine on 20/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

public struct UserMessageDto {
  
  // MARK: - Properties
  
  // Message Author
  
  var author: String
  var authorId: String
  var authorPic: String?
  var authorRole: Role?
  
  // Message Body
  
  var msgId: String
  var color: Int
  var createdAt: Int
  var type: MessageType
  
  // Message Options
  
  var love: Int
  var isOwn: Bool = false
  var status: OnGoingStatus?
  
  enum MessageType {
    case text(text: String)
    case media(mediaWith: MediaWith, format: MediaFormat, text: String?)
    case embed(text: String?, embed: EmbedDto)
    case joke(joke: String)
    case quote(quote: String)
    case blocked
    case deleted
  }
  
  enum MediaWith{
    case url(_: String)
    case image(_: UIImage)
  }
  
  enum MediaFormat : String {
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case png = "image/png"
  }
  
  enum OnGoingStatus {
    case sending
    case uploading(progression: Progress)
    case sent
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Init Methods
  
  init(type: MessageType, profile: UserDTO, id: String, status: OnGoingStatus?, isOwn: Bool){
    self.author = profile.name
    self.authorId = profile.id
    self.authorPic = profile.picture
    self.color = profile.color
    self.type = type
    self.createdAt = 0
    self.love = 0
    self.msgId = id
    self.status = status
    self.isOwn = isOwn
  }
  
  init(json: JSON) {

    if json["author"]["role"].exists() {
      self.authorRole = Role(rawValue: json["author"]["role"].stringValue)!
    }
    
    self.author = json["name"].stringValue
    self.authorId = json["authorId"].stringValue
    self.authorPic = json["author"]["picture"]["uri"].string
    self.msgId = json["id"].stringValue
    self.createdAt = json["createdAt"].intValue
    self.color = json["color"].intValue
    self.love = json["love"].intValue
    
    if json["deleted"].exists() {
      self.type = .deleted
    }
      
    else if json["joke"]["content"].exists() {
      self.type = .joke(joke: json["joke"]["content"].stringValue)
    }
      
    else if json["quote"]["content"].exists(){
      self.type = .quote(quote: json["quote"]["content"].stringValue)
    }
      
    else if json["media"].exists(){
      self.type = .media(mediaWith: .url(json["media"]["uri"].stringValue),
                         format: MediaFormat(rawValue: json["media"]["md"]["type"].stringValue)!,
                         text: json["text"].string)
    }
      
    else if json["embed"].exists(){
      self.type = .embed(
        text: json["text"].string,
        embed: EmbedDto(json: json["embed"]))
    }
      
    else {
      self.type = .text(text: json["text"].stringValue)
    }
    
  }
  
  init(author: String, authorId: String, authorRole: Role, msgId: String, color: Int,
       createdAt: Int, love: Int, type: MessageType, isOwn: Bool) {
    self.author = author
    self.authorId = authorId
    self.msgId = msgId
    self.createdAt = createdAt
    self.color = color
    self.love = love
    self.type = type
    self.isOwn = isOwn
    self.authorRole = authorRole
  }
}
