//
//  FeedEvent.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum FeedEvent {
  
  case notificationsLoaded(notifications: [FeedElement])
  case notificationsAdded(notification: FeedElement)
  case notificationUpdated(notification: FeedElement)
  case notificationDeleted(notificationId: String)
  
  case favoritesLoaded(favorites: [FeedElement])
  case favoriteAdded(favorite: FeedElement)
  case favoriteUpdated(favorite: FeedElement)
  case favoriteDeleted(favoriteId: String)
  
  case chatsLoaded(chats:[FeedElement])
  case chatAdded(chat:FeedElement)
  case chatUpdated(chat:FeedElement)
  case chatDeleted(chatId: String)
  
}
