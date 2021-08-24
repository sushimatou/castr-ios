//
//  MembersPresenter.swift
//  CastrApp
//
//  Created by Antoine on 05/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class MembersPresenter {
  
  static let instance = MembersPresenter()
  let interactor = ChatroomInteractor()
  var disposable: Disposable? = nil
  
  // MARK: - Properties
  
  
  
  // MARK: - Bind View
  
  func bind(view: MembersViewController) {

      self
        .interactor
        .getMembersList(chatroomId: view.chatroomId!, from: nil)
        .subscribe()
  
  }
  
  // MARK: - Reduce View State
  
  func reduceViewState() {
    
  }
  
  // MARK: - Unbind View
  
  func unbind() {
    disposable?.dispose()
  }
  
}
