//
//  DataChatMessages.swift
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

class DataChatMessages {
  
  static let dbRef = Database.database().reference()
  
  //MARK: - Socket Methods
  
  static func getChatEvents(chatId: String, uid: String)  -> Observable<ChatEvents> {
    return SocketApi
      .getInstance()
      .getChat(chatId: chatId)
      .flatMapLatest({ (chatApi) -> Observable<ChatEvents> in
        return chatApi.toObservable()
      })
  }
  static func genMessageId(chatId: String) -> String {
    let targetRef = dbRef.child("/chats/messages/\(chatId)").childByAutoId()
    let createdMessageId = targetRef.key
    return createdMessageId
  }
  
  
  static func sendMessage(chatId: String, message: String, uid: String) -> Observable<UserMessageDto> {
    return SocketApi
      .getInstance()
      .getChat(chatId: chatId)
      .flatMapLatest({ (chatApi) -> Observable<UserMessageDto> in
        print("data chat interactor - send message ")
        return chatApi.sendMessage(text: message)
      })
  }
  
  static func leave(chatId: String)  {
    SocketApi.getInstance().leaveChat(chatId: chatId)
  }
  
  static func sendImage(chatId: String, text: String?, uid: String, imageDatas: [String:Any]) -> Observable<Void> {
    return SocketApi
      .getInstance()
      .getChat(chatId: chatId)
      .flatMapLatest({ (chatApi) -> Observable<Void> in
        return chatApi.sendMessageWithData(mediaData: imageDatas, text: text)
      })
  }
  
  static func getMoreMessages(chatId: String, uid: String, fromMessageId: String) -> Observable<[MessageDto]> {
    
    return SocketApi
      .getInstance()
      .getChat(chatId: chatId)
      .take(1)
      .flatMap({ (chatApi) -> Observable<[MessageDto]> in
        return chatApi.requestMessagePage(fromMessageId: fromMessageId,uId: uid)
      })
  }
}
