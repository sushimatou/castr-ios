//
//  SignInInteractor.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import FirebaseAuth
import RxSwift

class SignInInteractor {
  
  func checkMail(mail: String) -> Observable<Bool> {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return Observable.just(emailTest.evaluate(with: mail))
  }
  
  func checkPwd(pwd: String) -> Observable<Bool> {
    return Observable.just(pwd.count > 6)
  }
  
  func signIn(email: String, pwd: String) -> Single<Result<Void>> {
    return FirebaseAuth
      .signIn(email: email, password: pwd)
      .map{
        return Result.success()
      }
      .catchError{ error in
        
        if let errorCode = AuthErrorCode(rawValue: error._code) {
          
          switch errorCode {
            
          case .invalidEmail:
            return Single.just(Result.failed(error: .invalidMail))
            
          case .wrongPassword:
            return Single.just(Result.failed(error: .invalidPassword))
            
          case .operationNotAllowed:
            return Single.just(Result.failed(error: .unauthorized))
            
          case .userDisabled:
            return Single.just(Result.failed(error: .unauthorized))
            
          default:
            return Single.just(Result.failed(error: .undefined))
          }
        }
        else {
          return Single.just(Result.failed(error: .undefined))
        }
    }
  }
  
}
