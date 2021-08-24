//
//  ChatroomSettingsPresenter.swift
//  CastrApp
//
//  Created by Antoine on 04/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class ChatroomSettingsPresenter {
  
  // MARK: - Properties
  
  static let instance = ChatroomSettingsPresenter()
  let interactor = ChatroomInteractor()
  var initState = ChatroomSettingsViewState()
  let relay = PublishSubject<ChatroomSettingsAction>()
  var disposable: Disposable? = nil
  
  // MARK : - Binding View
  
  func bind(view: ChatroomSettingsViewController){
    
    self.initState.initName = view.infos.name
    self.initState.initDescription = view.infos.description
    
    func obsChangeNameIntent() -> Observable<ChatroomSettingsAction> {
      return view
        .changeNameIntent()
        .filter{ name in
          if name == self.initState.initName {
            self.relay.onNext(.setNameState(state: .pristine))
            return false
          }
          else {
            return true
          }
        }
        .do(onNext: { name in
          self.relay.onNext(.setNameState(state: .loading))
        })
        .flatMap{ name in
          return self.interactor.isValidName(name: name)
        }
        .map{ isValid in
          if isValid {
            return .setNameState(state: .valid)
          }
          else {
            return .setNameState(state: .error(error: "Le nom doit contenir entre 1 et 40 caractères"))
          }
      }
    }
    
    func obsChangeDescriptionIntent() -> Observable<ChatroomSettingsAction> {
      return view
        .changeDescriptionIntent()
        .filter{ description in
          if description == self.initState.initDescription {
            self.relay.onNext(.setDescriptionState(state: .pristine))
            return false
          }
          else {
            return true
          }
        }
        .do(onNext: { _ in
          self.relay.onNext(.setDescriptionState(state: .loading))
        })
        .flatMap{ description in
          return self.interactor.isValidDescription(description: description)
        }
        .map{ isValid in
          if isValid {
            return .setDescriptionState(state: .valid)
          }
          else {
            return .setDescriptionState(state: .error(error: "La description doit contenir moins de 250 caractères"))
          }
      }
    }
    
    // TODO: - Change Picture
    
    func obsChangeColorIntent() -> Observable<ChatroomSettingsAction> {
      return view
        .changeColorIntent()
        .do(onNext: { color in
          self.relay.onNext(.changeColor(color: color))
        })
        .flatMap{ color in
          return self
            .interactor
            .changeChatroomColor(chatroomId: view.infos.id, color: color)
        }
        .map{_ in 
          return ChatroomSettingsAction.undefined
        }
    }

    // TODO: - Add Loading during saving changes
    
    func obsUpdateChatroomIntent() -> Observable<ChatroomSettingsAction> {
      return view
        .saveIntent()
        .flatMap{ updates in
          return self.interactor.updateChatroom(chatroomId: view.infos.id, name: updates.name,
                                                description: updates.description)
        }
        .map{ _ in
          return .updatesOk
        }
    }
    
    disposable = Observable
      .merge([obsChangeNameIntent(), obsChangeDescriptionIntent(), obsChangeColorIntent(), obsUpdateChatroomIntent(),relay])
      .scan(initState, accumulator: reduceViewState)
      .subscribe(onNext: { state in
        view.render(state: state)
      })
  }
  
  func reduceViewState(previousState: ChatroomSettingsViewState, changes: ChatroomSettingsAction) -> ChatroomSettingsViewState {
    
    var newState = previousState
    
    switch changes {
      
    case .setNameState(let state):
      newState.nameState = state
      return newState
      
    case .setDescriptionState(let state):
      newState.descriptionState = state
      return newState
      
    case .updatesOk:
      newState.nameState = .pristine
      newState.descriptionState = .pristine
      return newState
      
    case .changeColor(let color):
      newState.color = color
      return newState
    
    case .undefined:
      return newState
      
    }
  }
  
  // MARK : - Unbinding View
  
  func unbind() {
    disposable?.dispose()
  }
  
}
