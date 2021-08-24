//
//  FeedService.swift
//  CastrApp
//
//  Created by Antoine on 16/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class FeedService {
  
  // Properties
  
  static let instance = FeedService()
  private let feedSubject = PublishSubject<FeedServiceState>()
  private let deleteSubject = PublishSubject<FeedElement>()
  private var disposable: Disposable?
  private var feed : FeedServiceState?

  // MARK: - Public funcs
  
  public func start() {
    let obs = Observable.merge([self.joinFeedEvents(), self.watchFeedEvents()])
    self.disposable?.dispose()
    self.disposable = obs
      .scan(FeedServiceState(), accumulator: reduceFeed)
      .subscribe(onNext: { (feed) in
        self.feed = feed
        self.feedSubject.onNext(feed)
      })
  }
  
  public func stop() {
    self.feed = nil
    self.disposable?.dispose()
  }
  
  public func resume() {
    self.disposable?.dispose()
  }
  
  public func getFeed(sorting: FeedSorting) -> Observable<[FeedElement]> {
    switch sorting {
    case .chats:
      return self.toObservable().map{ feed in
        return feed.chats
      }
    case .favorites:
      return self.toObservable().map{ feed in
        return feed.favorites
      }
    case .notifications:
      return self.toObservable().map{ feed in
        return feed.notifications
      }
    }
  }
  
  func deleteFeedElement(element: FeedElement) -> Observable<Void> {
    return SocketApi
      .getInstance()
      .getFeed()
      .flatMapLatest({ (feedApi) -> Observable<Void> in
        print("feed service - delete element")
        switch element {
        case .notification(let notification):
          return feedApi.deleteNotification(notificationId: notification.id)
        case .favorite(let favorite):
          return feedApi.deleteFavorite(favId: favorite.id)
        case .chat(let chat):
          return feedApi.deleteChat(chatId: chat.id)
        }
      })
  }
  
  
  // MARK: - Private funcs
  
  fileprivate func toObservable() -> Observable<FeedServiceState> {
    if self.feed != nil {
      return Observable.concat(Observable.of(feed!), self.feedSubject)
    }
    else {
      return self.feedSubject
    }
  }
  
  fileprivate func joinFeedEvents() -> Observable<FeedEvent> {
    return SocketApi
      .getInstance()
      .getFeed()
      .flatMapLatest{ feedApi -> Observable<FeedEvent> in
        return feedApi.join()
    }
  }
  
  fileprivate func watchFeedEvents() -> Observable<FeedEvent> {
    return SocketApi
      .getInstance()
      .getFeed()
      .flatMapLatest({ (feedApi) -> Observable<FeedEvent> in
        return feedApi.observeEvents()
      })
  }
  
  func loadMore(sorting: FeedSorting, lastUpdate: Int) -> Observable<[FeedElement]> {
    return SocketApi
      .getInstance()
      .getFeed()
      .flatMapLatest { (feedApi) -> Observable<[FeedElement]> in
        return feedApi.requestPage(feedType: sorting.rawValue, fromDate: lastUpdate)
    }
  }
  
  
  // MARK: - Reduce Feed func 
  
  fileprivate func reduceFeed(feed: FeedServiceState, changes: FeedEvent) -> FeedServiceState {
    
    var newFeed = feed
    
    switch changes {
      
    case .notificationsLoaded(let notifications):
      newFeed.notifications = notifications
      
    case .notificationsAdded(let notification):
      newFeed.notifications.insert(notification, at: 0)
      
    case .notificationUpdated(let notification):
      if let index = newFeed.notifications.index(where: { (feedElement) -> Bool in
        return feedElement == notification
      }){
        newFeed.notifications[index] = notification
      }
      
    case .notificationDeleted(let notificationId):
      print("feed service - notification deleted")
      if let index = newFeed.notifications.index(where: { (feedElement) -> Bool in
        if case FeedElement.notification(let notification) = feedElement {
          return notification.id == notificationId
        } else {
          return false
        }
      }){
        newFeed.notifications.remove(at: index)
      }
      
    case .favoritesLoaded(let favorites):
      newFeed.favorites = favorites
      
    case .favoriteAdded(let favorite):
      newFeed.favorites.insert(favorite, at: 0)
      
    case .favoriteUpdated(let favorite):
      if let index = newFeed.favorites.index(where: { (feedElement) -> Bool in
        return feedElement == favorite
      }){
        newFeed.favorites[index] = favorite
      }
      
    case .favoriteDeleted(let favoriteId):
      if let index = newFeed.favorites.index(where: { (feedElement) -> Bool in
        if case FeedElement.favorite(let favorite) = feedElement {
          return favorite.id == favoriteId
        }else {
          return false
        }
      }){
        newFeed.favorites.remove(at: index)
      }
      
    case .chatsLoaded(let chats):
      newFeed.chats = chats
      
    case .chatAdded(let chat):
      newFeed.chats.insert(chat, at: 0)
      
    case .chatUpdated(let chat):
      if let index = newFeed.chats.index(where: { (feedElement) -> Bool in
        return feedElement == chat
      }){
        newFeed.chats[index] = chat
      }
      
    case .chatDeleted(let chatId):
      if let index = newFeed.chats.index(where: { (feedElement) -> Bool in
        if case FeedElement.chat(let chat) = feedElement {
          return chat.id == chatId
        } else {
          return false
        }
      }){
        newFeed.chats.remove(at: index)
      }
    }
    return newFeed
    }
}
