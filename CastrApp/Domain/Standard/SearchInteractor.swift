//
//  SearchInteractor.swift
//  CastrApp
//
//  Created by Antoine on 03/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class SearchInteractor {
  
  func autocompleteSearchChatroom(name: String) -> Observable<Result<[SearchResultsDto]>> {
    return FirebaseAuth
      .getToken()
      .flatMap{token in
        return DataChatrooms
          .chatroomsByName(name: name, token: token, type: "autocomplete")
          .flatMap{ results in
            return Observable.just(Result.success(results))
          }
          .catchError{ error in
            return Observable.just(Result.failed(error: CastrError.undefined))
          }
      }
  }
  
  func searchChatroom(name: String) -> Observable<[SearchResultsDto]> {
    return FirebaseAuth.getToken().flatMap{token in
      return DataChatrooms.chatroomsByName(name: name, token: token, type: "search")
    }
  }
  
}
