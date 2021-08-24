//
//  ChatApi.swift
//  CastrApp
//
//  Created by Antoine on 13/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift
import Birdsong
import SwiftyJSON

class ChatApi {
  
  // MARK: - Properties
  
  private let channel: Channel
  private let subject = PublishSubject<ChatEvents>()
  let id: String
  
  init(socket: Socket, id: String, uid: String) {
    self.id = id
    self.channel = socket.channel("chat:\(id)")
    
    // Messages Outgoing Events
    
    self.channel.on("message:sent") { (response) in
      print(response)
      let json = response.payload as [String : Any]
      let jsonRoot = json["message"]
      let jsonMessage = JSON(jsonRoot!)
      var userMessage = UserMessageDto(json: jsonMessage)
      if userMessage.authorId == uid {
        userMessage.isOwn = true
      }
      let message = MessageDto(json: jsonMessage, type: .userMessage(message: userMessage))
      self.subject.onNext(.messageSent(message: message))
    }
    
    self.channel.on("message:deleted") { response in
      let json = response.payload as [String : Any]
      let messageId = json["message_id"] as! String
      let deletedById = json["deleted_by"] as! String
      let deletedAt = json["deleted_at"] as! Int
      self.subject
        .onNext(ChatEvents.messageDeleted(messageId: messageId,
                                          userId: deletedById,
                                          deletedAt: deletedAt))
    }
    
    // Chatroom Outgoing Events
    
    self.channel.on("chat:updated") { response in
      let json = response.payload as [String : Any]
      let updates = json["updates"] as! [String : Any]
      self.subject
        .onNext(ChatEvents.chatroomUpdated(updates: updates))
    }
    
    self.channel.on("chat:deleted") { response in
      self.subject
        .onNext(ChatEvents.chatroomDeleted)
    }
    
    // Joining Channel
    
    self.channel.join()!
      .receive("ok") { (json) in
        print("chat api - joigned chat", json)
        var messages = [MessageDto]()
        let jsonRoot = json as [String : AnyObject]
        if let datas = jsonRoot["response"]!["messages"] as? [AnyObject] {
          for data in datas {
            let jsonMessage = JSON(data)
            var userMessage = UserMessageDto(json: jsonMessage)
            if userMessage.authorId == uid {
              userMessage.isOwn = true
            }
            let message = MessageDto(json: jsonMessage, type: .userMessage(message: userMessage))
            messages.append(message)
          }
        }
        
        if let infos = jsonRoot["response"]!["with"] as? [String : Any] {
          let jsonInfos = JSON(infos)
          let chatroomInfos = MessagingInfos.chat(ChatInfosDto(jsonChat: jsonInfos))
          self.subject.onNext(.load(messages: messages, infos: chatroomInfos))
        }
      }
      .receive("error") { (error) in
        self.subject.onError(SocketError.socketError)
    }
  }
  
  func toObservable() -> Observable<ChatEvents> {
    return subject.asObservable()
  }
  
  func leave(){
    self.channel.leave()
    print("chatroom api - chat leaved")
  }
  
  // Message Incoming Events
  
  func sendMessage(text: String) -> Observable<UserMessageDto> {
    
    return Observable.create { emitter in
      self.channel.send("message:send", payload: ["text": text])!
        .receive("ok") { (payload) in
          print("chat api- :", payload)
          if let response = payload["response"] {
            let jsonMessage = JSON(response)
            let message = UserMessageDto(json: jsonMessage)
            emitter.onNext(message)
          }
        }
        .receive("error") { (error) in
      }
      return Disposables.create()
    }
  }
  
  func sendMessageWithData(mediaData: [String:Any], text: String?) -> Observable<Void> {
    
    var messageData = mediaData
    
    if text != nil {
      messageData["text"] = text!
    }
    
    return Observable.create { emitter in
      self.channel.send("message:send_media", payload: messageData)!
        .receive("ok") { (payload) in
          emitter.onNext()
        }
        .receive("error") { (error) in
          print(error)
          emitter.onNext()
      }
      return Disposables.create()
    }
  }
  
  func deleteMessage(messageId: String) -> Observable<Void> {
    return Observable.create{ emitter in
      self.channel
        .send("message:deleted", payload: [:])!
        .receive("ok", callback: { (_) in
          
        })
        .receive("error", callback: { (_) in
          
        })
      return Disposables.create()
    }
  }
  
  func requestMessagePage(fromMessageId: String, uId: String) -> Observable<[MessageDto]> {
    return Observable.create{ emitter in
      self.channel
        .send("message:request_page", payload: ["from_id": fromMessageId])!
        .receive("ok", callback: { (json) in
          var messages = [MessageDto]()
          let jsonRoot = json as [String : AnyObject]
          if let datas = jsonRoot["response"]!["page"] as? [AnyObject] {
            for data in datas {
              let jsonMessage = JSON(data)
              var userMessage = UserMessageDto(json: jsonMessage)
              if userMessage.authorId == uId {
                userMessage.isOwn = true
              }
              let message = MessageDto(json: jsonMessage, type: .userMessage(message: userMessage))
              messages.append(message)
            }
            emitter.onNext(messages)
            emitter.onCompleted()
          }
        })
        .receive("error", callback: { (_) in
          
        })
      return Disposables.create()
    }
  }
  
}
