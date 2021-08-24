//
//  ChatroomInfosPresenter.swift
//  CastrApp
//
//  Created by Antoine on 28/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class ChatroomInfosPresenter {
  
  // MARK: - Properties
  
  static let instance = ChatroomInfosPresenter()
  fileprivate let interactor = ChatroomInteractor()
  fileprivate var disposable: Disposable?
  fileprivate var view: ChatroomInfosViewController?
  
  // MARK: - Binding/ Unbinding View
  
  public func bind(view: ChatroomInfosViewController){
    self.view = view
    self.disposable = Observable
      .merge(
      [obsGetAdministrators()])
      .scan(ChatroomInfosViewState(), accumulator: reduceViewState)
      .subscribe(onNext: { (state) in
        self.view!.render(state: state)
      })
  }
  
  public func unbind(){
    self.disposable?.dispose()
  }
  
  // MARK: - Observables
  
//  fileprivate func obsChatroomInfos() -> Observable<ChatroomInfosAction> {
//    return interactor
//      .getChatroomInfosDetails(chatroomId: view!.infos!.id)
//      .asObservable()
//      .map{ _ in
//        return .undefined
//      }
//  }
  
  fileprivate func obsGetAdministrators() -> Observable<ChatroomInfosAction> {
    return interactor
      .getAdmins(chatroomId: view!.infos!.id)
      .asObservable()
      .map{ admins in
        return .setAdmins(admins)
      }
  }

  // MARK: - Reduce Function
  
  fileprivate func reduceViewState(previousState: ChatroomInfosViewState, action: ChatroomInfosAction) -> ChatroomInfosViewState {
    var newState = previousState
    switch action {
    case .undefined:
      break
    case .setAdmins(let admins):
      newState.admins = admins
      
    case .setModos(_):
      break
    }
    return newState
  }
}
