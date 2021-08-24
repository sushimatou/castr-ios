//
//  DiscoveryInteracto.swift
//  CastrApp
//
//  Created by Castr on 07/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryInteractor {
  
  func getChatroomList(sorting: DiscoverySorting, rank: Double?) -> Observable<Result<[ChatroomDTO]>> {
    return FirebaseAuth.getToken()
      .flatMap{ token in
        return DataChatrooms
          .getChatroomList(token: token, sorting: sorting, rank: rank)
          .flatMap{ chatrooms in
            return Observable.just(Result.success(chatrooms))
          }
          .catchError({ (error) -> Observable<Result<[ChatroomDTO]>> in
            
            switch error {

            default:
              return Observable.just(.failed(error: .timeOut))

            }
          })
      }
  }
}
