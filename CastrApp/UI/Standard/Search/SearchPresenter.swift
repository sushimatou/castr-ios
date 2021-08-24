//
//  SearchPresenter.swift
//  CastrApp
//
//  Created by Antoine on 27/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift


class SearchPresenter {
  
  // MARK : - Properties
  
  static let instance = SearchPresenter()
  let interactor = SearchInteractor()
  let relay = PublishSubject<SearchAction>()
  var initState = SearchResultsViewState()
  var disposable: Disposable?
  
  // MARK : - Bind Method
  
  func bind(view: SearchResultsViewController){
    
    func obsAutocomplete() -> Observable<SearchAction> {
      return view
        .autocompleteSubject
        .do(onNext: { (_) in
          self.relay.onNext(.setLoading(loading: true))
        })
        .flatMap { query in
          return self.interactor.searchChatroom(name: query)
        }
        .map{ results in
          print(results)
          return .autcomplete(chatrooms: results)
      }
    }
    
    func obsSearch() -> Observable<SearchAction> {
      return view
        .autocompleteSubject
        .do(onNext: { (_) in
          self.relay.onNext(.setLoading(loading: true))
        })
        .flatMap { query in
          return self.interactor.searchChatroom(name: query)
        }
        .map{ results in
          print(results)
          return .autcomplete(chatrooms: results)
        }
    }
    
    disposable = Observable
      .merge([obsSearch(),obsAutocomplete(), relay])
      .scan(initState, accumulator: reduceViewState)
      .subscribe(onNext: { (newState) in
        view.render(state: newState)
      })
    
  }
  
  func unbind(view: SearchResultsViewController){
    
  }
  
  // MARK : - Reduce State Method
  
  func reduceViewState(previousState: SearchResultsViewState, changes: SearchAction) -> SearchResultsViewState {
    
    var newState = previousState
    
    switch changes {
    
    case .setLoading(let loading):
      newState.isLoading = loading
      return newState
      
    case .autcomplete(let chatrooms):
      newState.resultsByAutocomplete = chatrooms
      newState.isLoading = false
      return newState
      
    case .search(let chatrooms):
      newState.resultsBySearch = chatrooms
      newState.isLoading = false
      return newState
      
    }
  }
}
