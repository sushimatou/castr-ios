//
//  SignUpUsernamePresenter.swift
//  CastrApp
//
//  Created by Antoine on 05/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class SignUpUsernamePresenter {
  
  // Properties
  static let instance = SignUpUsernamePresenter()
  let interactor = SignUpInteractor()
  let relay = PublishSubject<SignUpUsernameAction>()
  let initState = SignUpUsernameViewState()
  var disposable: Disposable? = nil
  
  // Binding View
  func bind(view: SignUpUsernameViewController) {
    
    func obsUsernameEditIntent() -> Observable<SignUpUsernameAction> {
      return view
        .usernameEditIntent()
        .do(onNext: { (_) in
          self.relay.onNext(.setUsernameTextFieldState(state: .loading))
        })
        .debounce(0.5, scheduler: MainScheduler.instance)
        .filter{ text in
          text.count > 1
        }
        .flatMap{ username in
          return self.interactor.checkUsername(username: username)
        }
        .map{ isAvailable in
          if isAvailable {
            return .setUsernameTextFieldState(state: .valid)
          }
          else {
            return .setUsernameTextFieldState(state:FieldState.error(error: "Ce pseudonyme est déjà utilisé"))
          }
      }
    }
    
    func obsCreateAccountIntent() -> Observable<SignUpUsernameAction> {
      return view
        .createAccountIntent()
        .flatMap{ args in
          return UserService
            .instance
            .signUp(email: args.email,
                    password: args.password,
                    username: args.username)
        }
        .map{ result in
          switch result {
          case .success():
            return .signUpUser
          case .failed(let error):
            return .signUpError(error)
          }
        }
      }
    
    disposable = Observable
      .merge([obsUsernameEditIntent(),obsCreateAccountIntent(),relay])
      .scan(initState, accumulator: reduceViewState)
      .subscribe(onNext: { (state) in
        view.render(state: state)
      })
  }
  
  func reduceViewState(previousState: SignUpUsernameViewState, changes: SignUpUsernameAction) -> SignUpUsernameViewState{
    
    var newState = previousState
    
    switch changes {
    case .setUsernameTextFieldState(let state):
      newState.username = state
      newState.error = nil
      return newState
    case .signUpUser:
      newState.isConnected = true
      newState.error = nil
      return newState
    case .signUpError(let error):
      newState.isConnected = false
      newState.error = error
      return newState
    }
    
  }
  
  // Unbinding View
  func unbind(view: SignUpUsernameViewController){
    self.disposable?.dispose()
  }
}
