//
//  MemberDetailPresenter.swift
//  CastrApp
//
//  Created by Antoine on 19/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class MemberDetailPresenter {
  
  // ---------------------------------------------------------------------------------------------
  
  // MARK : - Properties
  
  static let instance = MemberDetailPresenter()
  private let initState = MemberDetailViewState()
  private let interactor = ChatroomInteractor()
  var view = MemberDetailViewController()
  var disposable: Disposable?
  
  // ---------------------------------------------------------------------------------------------
  
  // MARK : - Binding / Unbinding View
  
  func bind(view: MemberDetailViewController) {
    self.view = view
    self.disposable = Observable.merge([obsMemberDetails(),
                                        obsWarnIntent(),
                                        obsBanIntent()])
                                .scan(initState, accumulator: reduceViewState)
                                .subscribe(onNext: { (newState) in
                                  view.render(state: newState)
                                })
  }
  
  func unbind() {
    disposable?.dispose()
  }
  
  // ---------------------------------------------------------------------------------------------
  
  // MARK : - Observables
  
  func obsMemberDetails() -> Observable<MemberDetailAction> {
    return interactor
      .getMemberDetails(chatroomid: view.chatroomId,
                        memberId: view.userId)
      .map{ result in
        switch result {
        case .success(let memberDetails):
          return .loadMemberDetail(memberDetails)
        case .failed(let error):
          return .showError(error)
        }
      }
  }
  
//  func obsChangeRoleIntent() -> Observable<MemberDetailAction> {
//
//  }

  func obsWarnIntent() -> Observable<MemberDetailAction> {
    return view
      .warnSubject
      .flatMap{ reason in
        return self
          .interactor
          .warnMember(chatroomId: self.view.chatroomId,
                      memberId: self.view.userId,
                      reason: reason)
      }
      .map{ result in
        switch result {
        case .success():
          return .undefined
        case .failed(let error):
          return .showError(error)
        }
      }
  }
  
  func obsBanIntent() -> Observable<MemberDetailAction> {
    return view
      .banSubject
      .flatMap{ reason in
        return self
          .interactor
          .banMember(chatroomId: self.view.chatroomId,
                      memberId: self.view.userId,
                      reason: reason)
      }
      .map{ result in
        switch result {
        case .success():
          return .banMember
        case .failed(let error):
          return .showError(error)
        }
    }
  }

  // ---------------------------------------------------------------------------------------------
  
  // MARK : - Reduce View State
  
  func reduceViewState(previousState: MemberDetailViewState, actions: MemberDetailAction) -> MemberDetailViewState {
    var newState = previousState
    
    switch actions {

    case .loadMemberDetail(let memberDetails):
      newState.isLoading = false
      newState.memberDetails = memberDetails
      
    case .changeMemberRole(let role):
      newState.memberDetails?.role = role
      
    case .banMember:
      newState.memberDetails?.role = Role.banned
      
    case .showError(let error):
      newState.error = error
      
    case .undefined:
      break //NOOP
    }
    
    return newState
  }
}
