//
//  DataChatroomMessages.swift
//  CastrApp
//
//  Created by Antoine on 04/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import Alamofire
import SwiftyJSON
import RxSwift

class DataChatroomMessages {
  
  //MARK: - Properties
  
  static let storageRef = Storage.storage().reference()
  static let dbRef = Database.database().reference()

  // -----------------------------------------------------------------------------------------------
  
  //MARK: - Socket Event Method
  
  static func getChatroomEvents(chatroomId: String, uid: String)  -> Observable<ChatroomEvents> {
    return SocketApi
      .getInstance()
      .getChatroom(chatroomId: chatroomId)
      .flatMapLatest({ (chatroomApi) -> Observable<ChatroomEvents> in
        return chatroomApi.toObservable()
      })
  }
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK: - Socket Send Message Methods
  
  static func sendMessage(chatroomId: String, message: String, uid: String) -> Observable<UserMessageDto> {
    return SocketApi
      .getInstance()
      .getChatroom(chatroomId: chatroomId)
      .flatMapLatest({ (chatroomApi) -> Observable<UserMessageDto> in
        return chatroomApi.sendMessage(text: message)
      })
  }
  
  static func deleteMessage(chatroomId: String, messageId: String) -> Observable<Void> {
    return SocketApi
      .getInstance()
      .getChatroom(chatroomId: chatroomId)
      .flatMapLatest({ (chatroomApi) -> Observable<Void> in
        print("delete message - flatmap chatroom api")
        return chatroomApi.deleteMessage(messageId: messageId)
      })
  }
  
  static func sendImageMessage(chatroomId: String, text: String?, imageData: Data, uid: String, url: String, msgId: String, quotesIds: [String?]) -> Observable<UserMessageDto> {
    return SocketApi
      .getInstance()
      .getChatroom(chatroomId: chatroomId)
      .flatMapLatest({ (chatroomApi) -> Observable<UserMessageDto> in
        return chatroomApi.sendMessageWithData(url: url, msgId: msgId, imageData: imageData, text: text, quoteIds: quotesIds)
      })
  }

  // -----------------------------------------------------------------------------------------------
  
  //MARK: - Socket Love Message Method
  
  static func sendLove(chatroomId: String, messageId: String, loveAmount: Int, uid: String) -> Observable<String> {
    return SocketApi
      .getInstance()
      .getChatroom(chatroomId: chatroomId)
      .flatMapLatest({ (chatroomApi) -> Observable<String> in
        return chatroomApi.sendLove(messageId: messageId, lovesAmount: loveAmount)
      })
  }

  static func leave(chatroomId: String) {
    
    SocketApi.getInstance().leaveChatroom(chatroomId: chatroomId)
  }
  
  static func genMessageId(chatroomId: String) -> String {
      let targetRef = dbRef.child("/channels/messages/\(chatroomId)").childByAutoId()
      let createdMessageId = targetRef.key
      return createdMessageId
  }
  
  // -----------------------------------------------------------------------------------------------

  //MARK: - HTTP Requests 
  
  static func getJokeById(id: Int, token: String) -> Single<String> {
    
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    return Single.create{emitter in
      Alamofire.request("\(Config.endPoint)/jokes/\(id)", method: .get, headers: header)
        .responseJSON(completionHandler: { (response) in
          if let data = response.result.value as? [String: AnyObject]{
            let json = JSON(data)
            let joke = json["joke"].stringValue
            emitter(.success(joke))
          }
        })
      return Disposables.create()
    }
  }
  
  static func getQuoteById(id: Int, token: String) -> Single<String> {
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    
    return Single.create{ emitter in
      Alamofire.request("\(Config.endPoint)/quotes/\(id)", method: .get, headers: header)
        .responseJSON(completionHandler: { (response) in
          if let data = response.result.value as? [String: AnyObject]{
            let json = JSON(data)
            let quote = json["quote"].stringValue
            emitter(.success(quote))
          }
        })
      return Disposables.create()
    }
  }
  
  static func reportMessage(token: String, chatroomId: String, messageId: String, reason: String?) -> Single<Void> {
    let header: HTTPHeaders = ["Authorization": "Bearer \(token)"]
    var parameters = ["chatroom_id": chatroomId,
                      "message_id" : messageId]
    if reason != nil {
      parameters["comment"] = reason!
    }
    
    return Single.create{ emitter in
      Alamofire
        .request("\(Config.apiEndPoint)/report/message", method: .post, parameters: parameters, headers: header)
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
}

public enum FirebaseUploadStatus {
  case uploading(progress: Progress)
  case uploaded(url: URL)
}
