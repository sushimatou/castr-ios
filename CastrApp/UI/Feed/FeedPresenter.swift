//
//  FeedPresenter.swift
//  CastrApp
//
//  Created by Antoine on 04/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class FeedPresenter {
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK : - Properties
  
  let relay = PublishSubject<FeedAction>()
  var disposable: Disposable?
  var initState = FeedState()
  var view = FeedContentViewController()
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK : - Binding View
  
  func bind(view : FeedContentViewController) {
    self.view = view
    self.disposable = Observable
      .merge([
        obsGetFeed(),
        obsLoadMoreIntent(),
        obsDeleteFeedElementIntent(),
        relay
      ])
      .scan(initState, accumulator: reduceViewState)
      .subscribe(onNext: { (newState) in
        view.render(state: newState)
      })
  }
  
  func unbind() {
    self.disposable?.dispose()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK : - Loading Observables
  
  func obsGetFeed() -> Observable<FeedAction> {
    return FeedService
      .instance
      .getFeed(sorting: self.view.sorting!)
      .map{ feedElements in
          return .fetchFeedElements(feedElements)
      }
  }

  func obsLoadMoreIntent() -> Observable<FeedAction> {
    return self
      .view
      .loadMoreSubject
      .do(onNext: { (_) in
        self.relay.onNext(.setLoadMoreState(true))
      })
      .flatMap{ lastUdpate in
        return FeedService
          .instance
          .loadMore(sorting: self.view.sorting!, lastUpdate: lastUdpate)
      }
      .map{ feedElements in
        return FeedAction.fetchMoreFeedElements(feedElements)
      }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK : - Delete Observable
  
  func obsDeleteFeedElementIntent() -> Observable<FeedAction> {
    var feedElement: FeedElement?
    return self
      .view
      .deleteIntentSubject
      .flatMap({ (selectdFeedElement) -> Observable<Void> in
        feedElement = selectdFeedElement
        return FeedService
          .instance
          .deleteFeedElement(element: feedElement!)
      })
      .map{ _ in
        return FeedAction.deleteFeedElement(feedElement!)
      }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK : - Reduce View State
  
  func reduceViewState(previousState: FeedState, changes: FeedAction) -> FeedState {
    
    var newState = previousState
    
    switch changes {
      
    case .fetchFeedElements(let feedElements):
      newState.feedElements = feedElements
      newState.isEmpty = feedElements.count == 0
      newState.isAtBottom = feedElements.count < 20
      newState.isLoading = false
      
    case .fetchMoreFeedElements(let feedElements):
      if !newState.isLoadingMore {
        newState.isAtBottom = feedElements.count < 20
        newState.feedElements.append(contentsOf: feedElements)
      }
      newState.isLoading = false
      
    case .setLoadMoreState(let state):
      newState.isLoadingMore = state
      
    case .setError(let error):
      newState.error = error
      
    case .deleteFeedElement(let selectedFeedElement):
      break
//      if let index = newState.feedElements.index(where: { (feedElement) -> Bool in
//        return feedElement == selectedFeedElement
//      }){
//        print("feed presenter - notification deleted")
//        newState.feedElements.remove(at: index)
//      }
      
    case .undefined:
      break // NOOP
    }
    
    return newState
    
  }
}


