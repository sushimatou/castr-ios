//
//  CreateChatroomPresenter.swift
//  CastrApp
//
//  Created by Antoine on 25/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class CreateChatroomPresenter {
  
  // MARK : - Properties
  
  static let instance = CreateChatroomPresenter()
  let searchInteractor = SearchInteractor()
  let roomInteractor = CreateChatroomInteractor()
  let initState = CreateChatroomState(isEnabled: true, isLoading: true)
  let relay = PublishSubject<CreateChatroomAction>()
  var disposable : Disposable? = nil
  
  // MARK : - Binding view
  
  func bind(view: CreateChatroomViewController) {
    
    func obsSearchNameIntent() -> Observable<CreateChatroomAction> {
      return view
        .editNameIntent()
        .do(onNext: { _ in
          self.relay.onNext(.setIsLoading(isLoading: true))
        })
        .flatMap{ search in
          self.searchInteractor.searchChatroom(name: search)
        }
        .map{ results in
          return CreateChatroomAction.resultsChatrooms(results: results)
        }
        .do(onNext: { _ in
          self.relay.onNext(.setIsLoading(isLoading: false))
        })
    }
    
    func obsIsValidName() -> Observable<CreateChatroomAction> {
      
      return view
        .editNameIntent()
        .do(onNext: { _ in
          self.relay.onNext(.setNameFieldState(state: .loading))
        })
        .flatMap{ name in
          self.roomInteractor.isNameValid(name: name)
        }
        .map{ isValid in
          if isValid {
            return .setNameFieldState(state: .valid)
          }
          else {
            return .setNameFieldState(state: .error(error: "Le nom doit avoir entre 1 et 40 caractères"))
          }
        }
      
    }
    
    func obsCreateChatroomIntent() -> Observable<CreateChatroomAction> {
      return view
        .createChatroomIntent()
        .do(onNext: { _ in
          self.relay.onNext(.setIsLoading(isLoading: true))
        })
        .flatMap{ name in
          return self.roomInteractor.createChatroom(name: name!)
        }
        .map{ result in
          switch result {
            
          case .success(let createdId):
            return CreateChatroomAction.setCreatedId(createdId: createdId)
            
          case .failed(let error):
            return CreateChatroomAction.undefined
          }
        }
        .do(onNext: { _ in
          self.relay.onNext(.setIsLoading(isLoading: false))
        })
    }
    
    func obsIsConnected() -> Observable<CreateChatroomAction> {
      return self
        .roomInteractor
        .isConnected()
        .map{ isConnected in
          return CreateChatroomAction.setIsEnabled(isEnabled: isConnected)
        }
        .do(onNext: { _ in
          self.relay.onNext(.setIsLoading(isLoading: false))
        })
    }
    
    self.disposable = Observable
      .merge([obsSearchNameIntent(), obsIsValidName(), obsCreateChatroomIntent(), obsIsConnected(), relay])
      .scan(initState, accumulator: reduceViewState)
      .subscribe(onNext: { (state) in
                    view.render(state: state)},
                 onError: nil)
  }
  
  func reduceViewState(previousState: CreateChatroomState, changes: CreateChatroomAction) -> CreateChatroomState {
    
    var newState = previousState
    
    switch changes {

    case .resultsChatrooms(let results):
      newState.chatroomResults = results
      return newState
      
    case .setCreatedId(let createdId):
      newState.createdId = createdId
      return newState
      
    case .setIsLoading(let isLoading):
      newState.isLoading = isLoading
      return newState
      
    case .setIsEnabled(let isEnabled):
      newState.isEnabled = isEnabled
      return newState
      
    case .undefined:
      return newState
    
    case .setNameFieldState(let state):
      newState.chatroomNameState = state
      return newState
    }
    
  }
  
  func unbind(view: CreateChatroomViewController) {
    self.disposable?.dispose()
  }
  
  
}
