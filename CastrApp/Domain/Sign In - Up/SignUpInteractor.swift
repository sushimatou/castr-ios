//
//  SingUpInteractor.swift
//  CastrApp
//
//  Created by Antoine on 05/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class SignUpInteractor {
  
  func checkEmail(email: String) -> Observable<Bool> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataProfile.checkEmail(email: email, token: token)
    }
  }
  
  func checkUsername(username: String) -> Observable<Bool> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataProfile.checkUsername(username: username, token: token)
    }
  }
  
  func signUp(email: String, pwd: String, name: String){
    return 
  }
  
//  func signUp(email: String, pwd: String, name: String) -> Observable<Void> {
//    return FirebaseAuth
//      .signUp(email: email, password: pwd, username: name)
//      .flatMap{ _ in
//        return FirebaseAuth.getAuthUser().flatMap{ uid in
//          return FirebaseAuth.getToken().flatMap{ token in
//            return DataProfile.userUpdate(uid: uid, token: token, update: ["name": name])
//          }
//      }
//    }
//  }

}
