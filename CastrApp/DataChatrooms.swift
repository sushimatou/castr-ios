//
//  DataChatrooms.swift
//  CastrApp
//
//  Created by Antoine on 03/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

class DataChatrooms {
  
  // MARK : - HTTP Requests
  
  static func getChatroomList(token: String, sorting : DiscoverySorting, rank: Double?) -> Observable<[ChatroomDTO]> {
    
    var params : [String: Any]
    var type : String
    
    switch sorting {
    case .populars:
      type = "popular"
    case .actives:
      type = "active"
    case .recents:
      type = "recent"
    }
    
    if let rank = rank {
      params = ["from": rank,
                "type": type]
    }
    else { 
      params = ["from": "",
                "type": type]
    }
    
    let header = ["Authorization": "Bearer \(token)"]
    var chatroomList = [ChatroomDTO]()
    
    return Observable.create{ emitter in
    
      print("\(Config.apiEndPoint)/discovery")
      Alamofire.request("\(Config.apiEndPoint)/discovery", method: .get, parameters: params, headers: header)
       .validate()
       .responseJSON(completionHandler: { response in
        print(response)
         switch response.result {
          
         case .success:
          
           if let jsonRoot = response.result.value as? [String: AnyObject]{
            if let datas = jsonRoot["results"] as? [AnyObject]{
              for data in datas {
                let jsonChatroom = JSON(data)
                let chatroom = ChatroomDTO(jsonChatroom: jsonChatroom)
                chatroomList.append(chatroom)
              }
            emitter.onNext(chatroomList)
            }
          }
          
          case .failure(_):
              
            // Status Code Response
              
            if let statusCode = response.response?.statusCode {
              emitter.onError(ApiError(rawValue: statusCode)!)
            }
              
            else {
              emitter.onError(ApiError.undefined)
            }
        }
       })
      
      return Disposables.create()
    }
    
  }
  
  static func getChatroomById(id: String, token: String) -> Single<Void>{
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    return Single.create{emitter in
      Alamofire.request("\(Config.endPoint)/chatroom/\(id)", method: .get, headers: header)
        .validate()
        .responseJSON(completionHandler: { (response) in
          
          switch response.result {
            
          case .success:
            if let data = response.result.value as? [String: AnyObject]{
              let jsonChatroom = JSON(data)
              let chatroom = ChatroomDTO(jsonChatroom: jsonChatroom)
              emitter(.success())
            }

          case .failure(_):
  
              // Status Code Response
              
            if let statusCode = response.response?.statusCode {
              emitter(.error(ApiError(rawValue: statusCode)!))
            }
              
            else {
              emitter(.error(ApiError.undefined))
            }
          }
      })
      return Disposables.create()
    }
  }
  
  static func addFavorite(chatroomId: String, token: String) -> Observable<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameters = ["chatroom_id": chatroomId]
    
    return Observable.create{emitter in
      Alamofire.request("\(Config.apiEndPoint)/feed/favorites", method: .post, parameters: parameters, headers: header)
          .responseJSON(completionHandler: { (response) in
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
  
  static func deleteFavorite(chatroomId: String, token: String) -> Observable<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameters = ["chatroom_id": chatroomId]
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/feed/favorites", method: .delete, parameters: parameters, headers: header)
        .responseJSON(completionHandler: { (response) in
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
  
  
  static func chatroomsByName(name: String, token: String, type: String ) -> Observable<[SearchResultsDto]> {
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameters = ["q": name, "type": type ]
    var results = [SearchResultsDto]()
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/search/chatroom", method: .get, parameters: parameters, headers: header)
        .responseJSON(completionHandler: { response in
          
          print(response)
          
          switch response.result {
            
          case .success:
            
            if let jsonRoot = response.result.value as? [String: AnyObject]{
              if let jsonSearchResults = jsonRoot["search_results"] as? [String : AnyObject]{
                if let datas = jsonSearchResults["hits"]!["hits"] as? [AnyObject] {
                  for data in datas {
                    let jsonResult = JSON(data)
                    let result = SearchResultsDto(json: jsonResult)
                    results.append(result)
                  }
                  emitter.onNext(results)
                }
              }
            }
          case .failure(let error):
            
            emitter.onError(error)
          }
        })
      return Disposables.create()
    }
  }
  
  // Admin Methods ----------------------------------------------------------
  
  static func createChatroom(token: String, uid: String, name: String) -> Observable<String> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let parameter = ["creator": uid, "name": name]
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom", method: .post, parameters: parameter, headers: header)
        .validate()
        .responseJSON(completionHandler: { response in
          switch response.result {
          
          case .success :
            if let results = response.result.value as? [String : AnyObject]{
              let jsonResults = JSON(results)
              let id = jsonResults["id"].stringValue
              emitter.onNext(id)
            }
              
          case .failure(_) :
  
            switch response.response?.statusCode {
              
            case 400?:
              emitter.onError(CastrError.invalidChatroomName)
            case 401?:
              emitter.onError(CastrError.unauthorized)
            case 403?:
              emitter.onError(CastrError.unauthorized)
              
            default:
              break
              
            }
          }
        })
      return Disposables.create()
    }
  }
  
  static func updateChatroomFields(token: String, chatroomId: String, name: String?, description: String?) -> Observable<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    var parameters: [String:String] = [:]
    parameters["name"] = name
    parameters["description"] = description
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)", method: .patch, parameters: parameters, headers: header)
        .responseJSON(completionHandler: { response in
          
          switch response.result{

          case .success:
            emitter.onNext(())

          case .failure(let error):
            emitter.onError(error)
          
          }
        })
      return Disposables.create()
    }
    
  }
  
  static func updateChatroomColor(token: String, chatroomId: String, color: Int) -> Observable<Void>{
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    let parameter: [String:Int] = ["color" : color]
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)", method: .patch, parameters: parameter, headers: header)
        .validate()
        .responseJSON(completionHandler: { (response) in
          
          switch response.result {
          case .success:
            emitter.onNext(())
          case .failure(let error):
            emitter.onError(error)
          }
        })
      return Disposables.create()
    }
  }
  
  static func updateChatroomPicture(uid: String, token: String, url: String, imageData: Data, chatroomId: String) -> Observable<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    let image = UIImage(data: imageData)
    let width = Int(image!.size.width)
    let height =  Int(image!.size.height)
    
    let metadatas: [String:Any] = ["width": width,
                                   "height": height,
                                   "content_type": "image/jpeg",
                                   "bytes": imageData.count]
    
    let parameter : [String : Any] = ["picture": url,
                                      "md": metadatas]
    
    return Observable.create { emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)", method: .patch, parameters: parameter, headers: header)
        .responseJSON(completionHandler: { (response) in
          
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
  
  static func deleteChatroom() {
    // TODO
  }
  
  static func getAdmins(chatroomId: String, token: String) -> Single<[UserDTO]> {
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    return Single.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)/admins", method: .get, headers: header)
        .responseJSON(completionHandler: { (response) in
          print("GET ADMIN -", response)
          switch response.result {
          case .success(let admins):
            var adminList = [UserDTO]()
            if let admins = admins as? [[String:Any]]{
              for admin in admins {
                let jsonAdmin = JSON(admin)
                adminList.append(UserDTO(json: jsonAdmin))
              }
            }
            emitter(.success(adminList))
          case .failure(let error):
            emitter(.error(error))
          }
        })
      return Disposables.create()
    }
  }
  
  static func getMembersList(token: String, chatroomId: String, from: String? ) -> Observable<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    var parameters: [String:String]?
    
    if from != nil {
      parameters = ["from" : from!]
    }
    
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)/members", method: .get, parameters: parameters, headers: header)
        .validate()
        .responseJSON(completionHandler: { (response) in
          
          switch response.result {
            
          case .success(_):
            emitter.onNext()
            
          case .failure(_):
            break
          }
        })
      return Disposables.create()
    }
  }
  
  // Admin Member Actions
  
  static func getMemberDetails(token: String, chatroomId: String, memberId: String) -> Observable<MemberDetailDto> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)/members/\(memberId)", 
        method: .get , parameters: nil, headers: header)
            .responseJSON(completionHandler: { (response) in
              print("Member Detail", response)
                switch response.result {
                case .success:
                  if let result = response.result.value as? [String : AnyObject]{
                    let jsonResults = JSON(result)
                    let memberDetails = MemberDetailDto(json: jsonResults)
                    emitter.onNext(memberDetails)
                  }
                case .failure(let error):
                  emitter.onError(error)
                }
        })
      return Disposables.create()
    }
  }
  
  static func warnMember(token: String, chatroomId: String, memberId: String, reason: String? ) -> Observable<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    var parameters = ["warned_id": memberId]
    
    if reason != nil {
      parameters["reason"] = reason!
    }

    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)/members/warn",
                        method: .post ,
                        parameters: parameters, headers: header)
               .responseJSON(completionHandler: { (response) in
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
  
  static func banMember(token: String, chatroomId: String, memberId: String, reason: String?) -> Observable<Void> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    var parameters = ["warned_id": memberId]
    
    if reason != nil {
      parameters["reason"] = reason!
    }
    
    return Observable.create{ emitter in
      Alamofire.request("\(Config.apiEndPoint)/chatroom/\(chatroomId)/members/ban",
                        method: .post ,
                        parameters: parameters,
                        headers: header)
               .responseJSON(completionHandler: { (response) in
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
  
  static func blockMember(token: String, chatroomId: String, memberId: String) -> Single<Void> {
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    return Single.create{ emitter in
      Alamofire
        .request(
        "\(Config.apiEndPoint)/user/\(memberId)/blacklist",
        method: .post,
        headers: header)
        .responseJSON(completionHandler: { (response) in
          switch response.result{
          case .success(_):
            emitter(.success())
          case .failure(let error):
            emitter(.error(error))
          }
        })
      return Disposables.create()
    }
  }
  
  static func unblockMember(token: String, chatroomId: String, memberId: String) -> Single<Void> {
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    return Single.create{ emitter in
      Alamofire
        .request(
          "\(Config.apiEndPoint)/user/\(memberId)/blacklist",
          method: .delete,
          headers: header)
        .responseJSON(completionHandler: { (response) in
          switch response.result{
          case .success(_):
            emitter(.success())
          case .failure(let error):
            emitter(.error(error))
          }
        })
      return Disposables.create()
    }
  }
  
  static func getBlockedUsersList(token: String, chatroomId: String, memberId: String) -> Single<[UserDTO]>{
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    return Single.create{ emitter in
      Alamofire
        .request("\(Config.apiEndPoint)/user/\(memberId)/blacklist", method: .get, headers: header)
        .responseJSON(completionHandler: { (response) in
          switch response.result{
          case .success(let results):
            var blockedUsersList = [UserDTO]()
            if let results = results as? [String : AnyObject] {
              for result in results {
                let jsonResult = JSON(result)
                let blockedUser = UserDTO(json: jsonResult)
                blockedUsersList.append(blockedUser)
              }
              emitter(.success(blockedUsersList))
            }
            
          case .failure(let error):
            emitter(.error(error))
          }
        })
      return Disposables.create()
    }
  }
  
}
