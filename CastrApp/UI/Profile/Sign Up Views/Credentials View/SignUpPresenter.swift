//
//  SignUpPresenter.swift
//  CastrApp
//
//  Created by Antoine on 05/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class SignUpPresenter {
  
  //MARK : - Properties
  
  static let instance = SignUpPresenter()
  let interactor = SignUpInteractor()
  let initState = SignUpState(isEnabled: false)
  let relay = PublishSubject<SignUpAction>()
  let mailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
  var disposable: Disposable? = nil
  
  //MARK : - Binding View
  
  func bind(view: SignUpViewController){
    
    func obsMailEditing() -> Observable<SignUpAction> {
      
      return view.mailEditIntent()
        .do(onNext: { (_) in
          self.relay.onNext(.setMailTextFieldState(state: .loading))
        })
        .debounce(0.5, scheduler: MainScheduler.instance)
        .filter({ (mail) -> Bool in
          return (mail.range(of: self.mailRegex,
                             options: .regularExpression) != nil)
        })
        .flatMap{ mail in
          return self.interactor.checkEmail(email: mail)
        }
        .map{ registered in
          if registered {
            return .setMailTextFieldState(state: .error(error: "Cet e-mail est déjà utilisé"))
          }
          else {
            return .setMailTextFieldState(state: .valid)
          }
        }
    }
    
    func obsPwdEditing() -> Observable<SignUpAction> {
      
      return view.pwdEditIntent()
        .do(onNext: { (_) in
          self.relay.onNext(.setPwdTextFieldState(state: .loading))
        })
        .debounce(0.5, scheduler: MainScheduler.instance)
        .map{ pwd in
          
          if pwd.count < 6 {
            return .setPwdTextFieldState(state: .error(error: "Le mot de passe doit contenir au minimum 6 caractères"))
          }
          else {
            return .setPwdTextFieldState(state: .valid)
          }
      }
    }
    
    disposable = Observable
      .merge([obsMailEditing(),obsPwdEditing(),relay])
      .scan(initState, accumulator: reduceViewState)
      .subscribe(onNext: { (result) in
        view.render(state: result)
      })
    
  }
  
  //MARK : - Reducing State
  
  func reduceViewState(previousState: SignUpState, changes: SignUpAction) -> SignUpState{
    
    var newState = previousState
    
    switch changes {
    
    case .setMailTextFieldState(let state):
      newState.mail = state
      return newState
    case .setPwdTextFieldState(let state):
      newState.pwd = state
      return newState

    }
    
  }

  
  //MARK : - Unbinding View
  
  func unbind(view: SignUpViewController){
    self.disposable?.dispose()
  }

}
