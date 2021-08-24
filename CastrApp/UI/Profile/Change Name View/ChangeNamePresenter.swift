//
//  ChangeNamePresenter.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class ChangeNamePresenter {
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - Properties
    
    static let instance = ChangeNamePresenter()
    private let relay = PublishSubject<ChangeNameAction>()
    private let interactor = ProfileInteractor()
    private var initState = ChangeNameViewState.empty
    private var view = ChangeNameViewController()
    private var disposable: Disposable?
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - Binding / Unbinding View
    
    public func bind(view: ChangeNameViewController){
        self.view = view
        self.disposable = Observable
          .merge([obsEditNameIntent(),obsChangeNameIntent()])
          .scan(initState, accumulator: reduceViewState)
          .subscribe(onNext: { (newState) in
            self.view.render(state: newState)
          })
    }
    
    public func unbind(){
        self.disposable?.dispose()
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - Observables
    
    private func obsEditNameIntent() -> Observable<ChangeNameAction> {
        return view
            .nameEditIntent()
            .skip(1)
            .do(onNext: { (_) in
      self.relay.onNext(.changeViewState(.editing(nameFieldState: .loading)))
            })
            .debounce(0.5, scheduler: MainScheduler.instance)
            .flatMap{ name in
                return self
                  .interactor
                  .checkUsername(username: name)
            }
            .map{ isAvailable in
              if isAvailable {
                return .changeViewState(.editing(nameFieldState: .valid))
              }
              else {
                return .changeViewState(.editing(nameFieldState: .error(error: "Ce nom est déjà utilisé")))
              }
            }
    }
    
    private func obsChangeNameIntent() -> Observable<ChangeNameAction>{
        return view
          .changeNameIntent()
          .flatMap{ name in
            return UserService.instance.changeName(name: name)
          }
          .map{ result in
            switch result {
            case .success():
              return .changeViewState(.changeNameDone)
            case .failed(let error):
              return .changeViewState(.error(error))
            }
          }
    }
  
    // ---------------------------------------------------------------------------------------------
  
    // MARK : - Reduce View State
  
    private func reduceViewState(previousState: ChangeNameViewState, actions: ChangeNameAction) -> ChangeNameViewState {
    
      var newState = previousState
    
      switch actions {
      
      case .changeViewState(let viewState):
        newState = viewState
      
      }
    
      return newState
    
    }
    
}
