//
//  ProfilePresenter.swift
//  CastrApp
//
//  Created by Castr on 22/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class ProfilePresenter {
  
  // MARK: - Properties
  
  static let instance: ProfilePresenter = ProfilePresenter()
  var disposable: Disposable? = nil
  let initState = ProfileViewState.isLoading
  let relay = PublishSubject<ProfileAction>()
  
  // MARK: - All Observables
  
  func bind(view: ProfileViewController){
    
    // Load Profile Observable
    
    func obsProfile() -> Observable<ProfileAction> {
      return UserService
        .instance
        .toObservable()
        .map{ user in
          return .setProfile(user)
      }
    }
    
    // Generation Intent Observables -------------------------------------------------------
    
    func obsGenNewColorIntent() -> Observable<ProfileAction> {
      return view
        .genNewColorIntent()
        .do(onNext: { (color) in
          self.relay.onNext(.updateColor(color))
        })
        .debounce(0.5, scheduler: MainScheduler.instance)
        .flatMap{ color in
          return UserService.instance.changeColor(color: color)
        }
        .map{ result in
          switch result {
          case .success():
            return .undefined
          case .failed(let error):
            return .setError(error)
          }
          
      }
    }
    
    func obsGenNewNameIntent() -> Observable<ProfileAction> {
      return view
        .genNewNameIntent()
        .flatMap{ _ in
          return UserService.instance.genName()
        }
        .do(onNext: { result in
          switch result {
          case .success(let args):
            self.relay.onNext(.updateName("\(args.noun) "+"\(args.adj)"))
          case .failed(let error):
            self.relay.onNext(.setError(error))
          }
        })
        .debounce(0.5, scheduler: MainScheduler.instance)
        .flatMap({ (result) -> Observable<ProfileAction> in
          switch result {
          case .success(let args):
            return UserService
              .instance
              .changeName(name: "\(args.noun) "+"\(args.adj)")
              .map { _ in return .undefined }
              .asObservable()
          case .failed(let error):
            return Observable.just(.setError(error))
          }
        })
    }
    
    // Log In / Out Intents ------------------------------------------------------------------------
    
    func obsLogOutIntent() -> Observable<ProfileAction> {
      return view
        .logOutSubject
        .do(onNext: { (_) in
          self.relay.onNext(.setLoading)
        })
        .flatMap{ _ in
          return UserService.instance.logOut()
        }
        .map{ _ in
          return .setLoading
        }
    }
    
    disposable = Observable
      .merge([obsProfile(),
              obsLogOutIntent(),
              obsGenNewNameIntent(),
              obsGenNewColorIntent(),
              relay])
      .scan(initState, accumulator: reduceViewState)
      .subscribe(onNext: { state in
        view.render(state: state)}
      )
  }
  
  // MARK: - Transforming State --------------------------------------------------------------------
  
  func reduceViewState(previousState: ProfileViewState, changes: ProfileAction) -> ProfileViewState {
    
    var newState = previousState
    
    switch changes {
      
    case .setProfile(let profile):
      print(profile)
      newState = .profile(user: profile)
      return newState
      
    case .setLoading:
      newState = .isLoading
      return newState
      
    case .setError(let error):
      newState = .error(error: error)
      return newState
      
    case .updateName(let name):
      if case let ProfileViewState.profile(user) = newState {
        var user = user
        user.name = name
        newState = .profile(user: user)
        print("user presenter - reducer new profile")
      }
      
      return newState
      
    case .updateColor(let color):
      
      if case let ProfileViewState.profile(user) = newState {
        var user = user
        user.color = color
        newState = .profile(user: user)
      }
      return newState
      
    case .updatePicture(let picPath):
      
      if case let ProfileViewState.profile(user) = newState {
        var user = user
        user.picture = picPath
        newState = .profile(user: user)
      }
      
      return newState
      
    case .updateLove(let love):
      
      if case let ProfileViewState.profile(user) = newState {
        var user = user
        user.loves = love
        newState = .profile(user: user)
      }
      
      return newState
    
    case .updateMessage(let message):
      
      if case let ProfileViewState.profile(user) = newState {
        var user = user
        user.messages = message
        newState = .profile(user: user)
      }
      return newState
      
    case .undefined:
      return newState
    }
  }
  
  // MARK: - Unbinding View & Dispose observables --------------------------------------------------
  
  func unbind(view: ProfileViewController) {
    disposable?.dispose()
    disposable = nil
  }
  
}

