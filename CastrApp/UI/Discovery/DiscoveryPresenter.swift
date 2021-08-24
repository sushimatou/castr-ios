//
//  DiscoveryPresenter.swift
//  CastrApp
//
//  Created by Antoine on 31/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryPresenter {

  let interactor = DiscoveryInteractor()
  let initState = DiscoveryViewState()
  let relay = PublishSubject<DiscoveryAction>()
  var view: DiscoveryContentViewController?
  var disposable: Disposable?
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Bind/ Unbind
  
  
  public func bind(view: DiscoveryContentViewController) {
    self.view = view
    self.disposable =
      Observable.merge([obsFetchChatroomList(),
                        obsFetchMoreChatroomList()])
                .scan(initState, accumulator: reduceViewState)
                .subscribe(onNext: { (newState) in
                  view.render(state: newState)
                })
  }
  
  public func unbind() {
    self.disposable?.dispose()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Observables
  
  private func obsFetchChatroomList() -> Observable<DiscoveryAction> {
    return interactor
      .getChatroomList(sorting: self.view!.sorting!,
                       rank: nil)
      .map{ result in
        switch result {
        case .success(let chatroomList):
          return DiscoveryAction.fetchChatroomList(chatroomList: chatroomList)
        case .failed(let error):
          return DiscoveryAction.error(error)
        }
    }

  }
  
  private func obsFetchMoreChatroomList() -> Observable<DiscoveryAction> {
    return view!
      .loadMoreSubject
      .do(onNext: { (_) in
        self.relay.onNext(.setLoadingMoreState(state: true))
      })
      .flatMap{ rank in
        return self.interactor
          .getChatroomList(sorting: self.view!.sorting!,
                           rank: rank)
          .map{ result in
            switch result {
            case .success(let chatroomList):
              return DiscoveryAction.fetchMoreChatrooms(chatroomList: chatroomList)
            case .failed(let error):
              return DiscoveryAction.error(error)
            }
        }
    }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Reduce View State
  
  private func reduceViewState(previousState: DiscoveryViewState, action: DiscoveryAction) -> DiscoveryViewState {
    
    var newState = previousState
    
    switch action {
      
    case .undefined:
      break //NOOP
      
    case .fetchChatroomList(let chatroomList):
      newState.chatroomList = chatroomList
      
    case .fetchMoreChatrooms(let chatroomList):
      if !newState.isLoadingMore {
        
        if chatroomList.count < 10 {
          newState.isAtBottom = true
        }
        for newChatroom in chatroomList {
          if !newState.chatroomList.contains(where: { (chatroom) -> Bool in
            return chatroom.id == newChatroom.id
          }){
            newState.chatroomList.append(newChatroom)
          }
        }
        newState.chatroomList = newState.chatroomList.sorted(by: { (first, second) -> Bool in
          return second.rank > first.rank
        })
        
        return newState
      }
  
      
    case .setLoadingMoreState(let state):
      newState.isLoadingMore = state

      
    case .error(let error):
      newState.error = error
    }
    
    return newState
  }
}

