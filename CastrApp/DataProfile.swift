//
//  DataProfile.swift
//  CastrApp
//
//  Created by Antoine on 07/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import Birdsong
import SwiftyJSON

class DataProfile {
  
  // MARK: - Properties
  
  let disposeBag = DisposeBag()
  
  // MARK: Socket Events Method
  
  
  // MARK: HTTP Requests
  
  static func checkEmail(email: String, token: String) -> Single<Bool> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameter = ["email": email]
    
    return Single.create { emitter in
      Alamofire.request("\(Config.apiEndPoint)/auth/check_email", method: .get, parameters: parameter, headers: header)
        .responseJSON(completionHandler: { (response) in
          if let data = response.value as? [String: AnyObject] {
            let json = JSON(data)
            let registered = json["registered"].boolValue
            emitter(.success(registered))
          }
        })
      return Disposables.create()
    }
  }
  
  static func blockUser(userId: String, token: String, blackListedUserId: String)-> Single<String> {
    let parameter = ["blacklisted_id" : blackListedUserId]
    let header = ["Authorization": "Bearer \(token)"]
    
    return Single.create{ emitter in
      Alamofire
        .request(
          "\(Config.apiEndPoint)/user/\(userId)/blacklist",
          method: .post,
          parameters: parameter,
          headers: header)
        .responseJSON(completionHandler: { (response) in
          switch response.result{
          case .success(_):
            emitter(.success(blackListedUserId))
          case .failure(let error):
            emitter(.error(error))
          }
        })
      return Disposables.create()
    }
  }
  
  static func getBlacklist(userId: String, token: String)-> Single<[String]> {
    let header = ["Authorization": "Bearer \(token)"]
    
    return Single.create{ emitter in
      Alamofire
        .request(
          "\(Config.apiEndPoint)/user/\(userId)/blacklist",
          method: .get,
          headers: header)
        .responseJSON(completionHandler: { (response) in
          switch response.result{
          case .success(_):
            var list = [String]()
            if let users = response.result.value as? [String : AnyObject]{
              for user in users {
                let jsonUser = JSON(user)
                let blackListedUser = jsonUser.stringValue
                list.append(blackListedUser)
              }
              emitter(.success(list))
            }
          case .failure(let error):
            emitter(.error(error))
            
          }
        })
      return Disposables.create()
    }
  }
  
  static func unblockUser(userId: String, token: String, blackListedUserId: String)-> Single<String> {
    let parameter = ["blacklisted_id" : blackListedUserId]
    let header = ["Authorization": "Bearer \(token)"]
    
    return Single.create{ emitter in
      Alamofire
        .request(
          "\(Config.apiEndPoint)/user/\(userId)/blacklist",
          method: .delete,
          parameters: parameter,
          headers: header)
        .responseJSON(completionHandler: { (response) in
          switch response.result{
          case .success(_):
            emitter(.success(blackListedUserId))
          case .failure(let error):
            emitter(.error(error))
          }
        })
      return Disposables.create()
    }
  }
  
  static func checkUsername(username: String, token: String) -> Single<Bool> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameter = ["username": username]
    
    return Single.create {emitter in
      Alamofire.request("\(Config.apiEndPoint)/auth/check_username", method: .get, parameters: parameter, headers: header)
        .responseJSON(completionHandler: { (response) in
          
            if let data = response.value as? [String: AnyObject] {
              let json = JSON(data)
              let isAvailable = json["available"].boolValue
              emitter(.success(isAvailable))
            }
            else {
              emitter(.success(true))
            }
        })
      return Disposables.create()
    }
  }
  
  static func userUpdate(uid: String, token: String, update: [String:Any]) -> Single<Void> {
    print("user data - user update")
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameter = update
    
    return Single.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/user/\(uid)", method: .patch, parameters: parameter, headers: header)
        .response(completionHandler: { (response) in
          print(response)
        })
      return Disposables.create()
      }
  }
  
  static func signUp(email: String, password: String, username: String, token: String) -> Single<Void> {
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameters : [String : String] = ["email": email,
                                          "password": password,
                                          "username": username]
    
    return Single.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/auth/register", method: .post, parameters: parameters, headers: header)
        .responseJSON(completionHandler: { (response) in
          print(response.result)
          switch response.result {
          case .success(_):
            emitter(.success())
          case .failure(let error):
            emitter(.error(error))
          }
        })
      return Disposables.create()
    }
    
  }
  
  static func notificationSettingUpdate(setting: String, value: Bool, token: String, uid: String) -> Single<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameter = ["setting" : value]
    
    return Single.create{ emitter in
      Alamofire.request("\(Config.endPoint)/user/\(uid)/notification/settings", method: .patch, parameters: parameter, headers: header).responseJSON(completionHandler: { (response) in
        switch response.result {
        case .success(_):
          emitter(.success())
        case .failure(let error):
          emitter(.error(error))
        }
      })
      return Disposables.create()
    }
  }
  
  static func userPictureUpdate(uid: String, token: String, url: String, imageData: Data) -> Observable<Void> {
    
    print("sending image to API")
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let image = UIImage(data: imageData)
    let width = Int(image!.size.width)
    let height =  Int(image!.size.height)
    
    let metadatas: [String:Any] = ["width": width,
                                   "height": height,
                                   "bytes": imageData.count]
    
    let parameters : [String : Any] = ["picture": url,
                                       "md": metadatas]
    
    return Observable.create { emitter in
      Alamofire.request("\(Config.apiEndPoint)/user/\(uid)", method: .patch, parameters: parameters, headers: header)
        .responseJSON(completionHandler: { (response) in
          print("USER PICTURE UPDATE", response)
        switch response.result {
        case .success:
          emitter.onNext()
        case .failure(let error):
          emitter.onError(error)
        }
      })
      return Disposables.create()
    }
  }
}
