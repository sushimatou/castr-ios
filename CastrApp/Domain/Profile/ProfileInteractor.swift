//
//  ProfileInteractor.swift
//  CastrApp
//
//  Created by Castr on 23/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseAuth

class ProfileInteractor {
  
  func checkUsername(username: String) -> Observable<Bool> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataProfile.checkUsername(username: username, token: token)
      }
  }

}



