//
//  SignInPresenter.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class SignInPresenter {
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Properties
  
  public static let instance = SignInPresenter()
  private let initState = SignInViewState.empty
  private let interactor = SignInInteractor()
  private let relay = PublishSubject<SignInAction>()
  private var view = SignInViewController()
  private var disposable : Disposable?
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Bind/ Unbind View
  
  func bind(view: SignInViewController) {
    self.view = view
    self.disposable = Observable.merge([obsMailEditIntent(),
                                        obsPwdIntent(),
                                        obsSignInIntent()])
                                .scan(initState, accumulator: reduceViewState)
                                .subscribe(onNext: { (newState) in
                                  view.render(state: newState)
                                })
  }
  
  func unbind() {
    self.disposable?.dispose()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Observables
  
  private func obsMailEditIntent() -> Observable<SignInAction>{
    return view
      .mailEditIntent()
      .do(onNext: { (_) in
        self.relay.onNext(.changeMailTxtFieldState(.loading))
      })
      .flatMap({ (mail) -> Observable<Bool> in
        return self.interactor.checkMail(mail: mail)
      })
      .map{ isValid in
        if isValid {
          return .changeMailTxtFieldState(.valid)
        }
        else {
          return .changeMailTxtFieldState(.error(error: "Mail non valide"))
        }
      }
  }
  
  private func obsPwdIntent() -> Observable<SignInAction> {
    return view
      .mailEditIntent()
      .do(onNext: { (_) in
        self.relay.onNext(.changeMailTxtFieldState(.loading))
      })
      .flatMap({ (pwd) -> Observable<Bool> in
        return self.interactor.checkPwd(pwd: pwd)
      })
      .map{ isValid in
        if isValid {
          return .changePwdTxtFieldState(.valid)
        }
        else {
          return .changePwdTxtFieldState(.error(error: "Le mot de passe contient au minimum 6 caractères"))
        }
    }
  }
  
  private func obsSignInIntent() -> Observable<SignInAction> {
    return view.signInIntent()
      .do(onNext: { (_) in
        self.relay.onNext(.changeViewState(.loading))
      })
      .flatMap{ credentials in
        return self.interactor.signIn(email: credentials.mail,
                                      pwd: credentials.pwd)
      }
      .map{ result in
        switch result {
        case .success(_):
          return .changeViewState(.connected)
        case .failed(let error):
          return .changeViewState(.error(error))
        }
      }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Reduce View State
  
  private func reduceViewState(previousState: SignInViewState, actions: SignInAction) -> SignInViewState {
    
    var newState = previousState
    
    switch actions {
      
    case .changeViewState(let viewState):
      newState = viewState
      
    case .changeMailTxtFieldState(let mailFieldState):
      if case SignInViewState.editing(_, let pwdState) = newState {
        newState = SignInViewState.editing(mail: mailFieldState, pwd: pwdState)
      } else {
        newState = SignInViewState.empty
      }
      
    case .changePwdTxtFieldState(let pwdFieldState):
      if case SignInViewState.editing(let mailState, _) = newState {
        newState = SignInViewState.editing(mail: mailState, pwd: pwdFieldState)
      } else {
        newState = SignInViewState.empty
      }
      
    }
    
    return newState
  }
}
