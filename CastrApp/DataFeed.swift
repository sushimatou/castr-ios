//
//  DataFeed.swift
//  CastrApp
//
//  Created by Antoine on 04/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class DataFeed {
  static func getFeedEvents() -> Observable<FeedEvent> {
    return Observable.merge([joinFeed(), watchFeedEvents()])
  }
  
  private static func joinFeed() -> Observable<FeedEvent> {
    return SocketApi
      .getInstance()
      .getFeed()
      .flatMapLatest { (feedApi) -> Observable<FeedEvent> in
        feedApi.join()
      }
  }
  
  private static func watchFeedEvents() -> Observable<FeedEvent> {
    return SocketApi
      .getInstance()
      .getFeed()
      .flatMapLatest { (feedApi) -> Observable<FeedEvent> in
        feedApi.observeEvents()
      }
  }
}
