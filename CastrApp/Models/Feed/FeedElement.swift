//
//  FeedDto.swift
//  CastrApp
//
//  Created by Antoine on 03/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum FeedElement {
  case notification(NotificationDto)
  case favorite(FavoriteDto)
  case chat(ChatDto)
}

extension FeedElement: Equatable {
  static func ==(lhs: FeedElement, rhs: FeedElement) -> Bool {
    switch(lhs, rhs) {
    case (let .notification(notification1), let.notification(notification2)):
      return notification1.id == notification2.id
    case (let .favorite(favorite1), let favorite(favorite2)):
      return favorite1.id == favorite2.id
    case (let .chat(chat1), let chat(chat2)):
      return chat1.id == chat2.id
    default:
      return false
    }
  } 
}
