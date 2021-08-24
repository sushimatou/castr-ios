//
//  FeedApi.swift
//  CastrApp
//
//  Created by Antoine on 01/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import Birdsong
import SwiftyJSON
import RxSwift

class FeedApi {
  
  //MARK : - Properties
  
  let channel: Channel
  let subject = PublishSubject<FeedEvent>()
  let uid : String
  
  init(socket: Socket, uid: String){
    self.uid = uid
    self.channel = socket.channel(("feed:\(uid)"))
    
    // Notifications Events
    
    self.channel.on("notification:updated") { (response) in
//      let json = response.payload as? [String : Int] {
////        self.subject.onNext(.notificationUpdated(notification: []))
//      }
    }

    self.channel.on("notification:deleted") { (response) in
      print("feed api - notification deleted channel event", response.payload)
      let jsonResponse = JSON(response.payload)
      let notificationId = jsonResponse["id"].stringValue
      self.subject.onNext(FeedEvent.notificationDeleted(notificationId: notificationId))
    }

    // Favorites Events

    self.channel.on("favorite:added") { (response) in
      if let json = response.payload as? [String : Int] {
        print("favorite added:",json)
//        self.subject.onNext(.favoriteAdded)
      }
    }

    self.channel.on("favorite:deleted") { (response) in
      let jsonResponse = JSON(response.payload)
      let favId = jsonResponse["response"]["id"].stringValue
      self.subject.onNext(.favoriteDeleted(favoriteId: favId))
    }

    self.channel.on("favorite:updated") { (response) in
      let jsonResponse = JSON(response.payload)
      let favoriteId = jsonResponse["id"].stringValue
      self.subject.onNext(FeedEvent.favoriteDeleted(favoriteId: favoriteId))
    }

    // Chats Events

    self.channel.on("chat:added") { (response) in
//      if let json = response.payload as? [String : Int] {
////        self.subject.onNext(.chatAdded)
//      }
    }

    self.channel.on("chat:deleted") { (response) in
      let jsonResponse = JSON(response.payload)
      let chatId = jsonResponse["id"].stringValue
      self.subject.onNext(.chatDeleted(chatId: chatId))
    }

    self.channel.on("chat:updated") { (response) in
      if let json = response.payload as? [String : Int] {
//        self.subject.onNext(.chatUpdated)
      }
    }

  }

  func observeEvents() -> Observable<FeedEvent> {
    return self.subject.asObservable()
  }
  
  func join() -> Observable<FeedEvent> {
    return Observable.create({ (emitter) -> Disposable in
      self.channel.join()!
        .receive("ok", callback: { (json) in
          
          let jsonRoot = json as [String : AnyObject]
          if let chatDatas = jsonRoot["response"]!["chats"] as? [AnyObject] {
            var chats = [FeedElement]()
            for chat in chatDatas {
              let jsonChat = JSON(chat)
              let chat = ChatDto(json: jsonChat)
              chats.append(FeedElement.chat(chat))
            }
            emitter.onNext(.chatsLoaded(chats: chats))
          }
          
          if let favDatas = jsonRoot["response"]!["favorites"] as? [AnyObject] {
            var favorites = [FeedElement]()
            for favorite in favDatas {
              let jsonFavorite = JSON(favorite)
              let favorite = FavoriteDto(json: jsonFavorite)
              favorites.append(FeedElement.favorite(favorite))
            }
            emitter.onNext(.favoritesLoaded(favorites: favorites))
          }
          
          if let jsonNotifications = jsonRoot["response"]!["notifications"] as? [AnyObject] {
            var notifications = [FeedElement]()
            for notification in jsonNotifications {
              let jsonNotification = JSON(notification)
              let notification = NotificationDto(json: jsonNotification)
              notifications.append(FeedElement.notification(notification))
            }
            emitter.onNext(.notificationsLoaded(notifications: notifications))
          }
          
          emitter.onCompleted()
        })
        .receive("error", callback: { (error) in
          // emitter.onError()
          emitter.onCompleted()
        })
      return Disposables.create()
    })
  }

  // Incoming Events
  
  func requestPage(feedType: String, fromDate: Int) -> Observable<[FeedElement]> {
    return Observable.create{ emitter in
      self.channel
        .send("feed:request_page", payload:
          ["type" : feedType,
           "from_date": fromDate])?
        .receive("ok", callback: { (response) in
          emitter.onNext([])
          print(response)
        })
        .receive("error", callback: { (_) in
          
        })
      return Disposables.create()
    }
  }

  func deleteChat(chatId: String) -> Observable<Void> {
    return Observable.create{ emitter in
      self.channel
        .send("chat:delete", payload: ["id" : chatId])?
        .receive("ok", callback: { (response) in
          print("Delete chat", response)
          emitter.onNext()
          emitter.onCompleted()
        })
        .receive("error", callback: { (_) in
          emitter.onError(CastrError.cantDelete)
        })
      return Disposables.create()
    }
  }
  
  func deleteFavorite(favId: String) -> Observable<Void> {
    return Observable.create{ emitter in
      self.channel
        .send("favorite:delete", payload: ["id" : favId])?
        .receive("ok", callback: { (response) in
          print("Feed Api - Delete favorite success", response)
          emitter.onNext()
          emitter.onCompleted()
        })
        .receive("error", callback: { (error) in
          emitter.onError(CastrError.cantDelete)
        })
      return Disposables.create()
    }
  }

  func deleteNotification(notificationId: String) -> Observable<Void>{
    return Observable.create{ emitter in
      self.channel
        .send("notification:delete", payload: ["id": notificationId])?
        .receive("ok", callback: { (response) in
          print("feed api - notification deleted", response)
          emitter.onNext()
          emitter.onCompleted()
        })
        .receive("error", callback: { (_) in
          emitter.onError(CastrError.cantDelete)
        })
      return Disposables.create()
    }
  }
  
}
