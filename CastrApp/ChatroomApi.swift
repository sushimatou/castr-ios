//
//  ChatroomApi.swift
//  CastrApp
//
//  Created by Antoine on 29/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import Birdsong
import SwiftyJSON
import RxSwift

class ChatroomApi {
  
  // MARK: - Properties
  
  private let channel: Channel
  private let subject = PublishSubject<ChatroomEvents>()
  let id: String
  
  init(socket: Socket, id: String, uid: String) {
    self.id = id
    self.channel = socket.channel("chatroom:\(id)")
    
    // ---------------------------------------------------------------------------------------------
    
    // Messages Outgoing Events
    
    self.channel.on("message:sent") { (response) in
      print("chatroom api - recevied new message")
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
    
    self.channel.on("message:loved") { response in
      print("chatroom api - recevied new love")
      let json = response.payload as [String : Any]
      let messageId = json["message_id"] as! String
      let loveAmount = json["love_amount"] as! Int
      let loveCount = json["love_count"] as! Int
      self.subject
        .onNext(.messageLoved(messageId: messageId,
                                        loveAmount: loveAmount,
                                        loveCount: loveCount))
    }
    
    self.channel.on("message:deleted") { response in
      print("chatroom api - new message deleted", response)
      let json = response.payload as [String : Any]
      let messageId = json["message_id"] as! String
      let deletedById = json["deleted_by"] as! String
      let deletedAt = json["deleted_at"] as! Int
      self.subject
        .onNext(ChatroomEvents.messageDeleted(messageId: messageId,
                                                        userId: deletedById,
                                                        deletedAt: deletedAt))
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // Chatroom Outgoing Events
    
    self.channel.on("chatroom:updated") { response in
      print("chatroom api - chatroom updated")
      let json = response.payload as [String : Any]
      let updates = json["updates"] as! [String : Any]
      self.subject
        .onNext(ChatroomEvents.chatroomUpdated(updates: updates))
    }
    
    self.channel.on("chatroom:deleted") { response in
      print("chatroom api - chatroom deleted")
      self.subject
        .onNext(ChatroomEvents.chatroomDeleted)
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // User Outgoing Events
    
    self.channel.on("message:deleted") { (response) in
      let reponseData = response.payload as [String : Any]
      let json = JSON(reponseData)
      let messageId = json["message_id"].stringValue
      let deletedBy = json["deleted_by"].stringValue
      let deletedAt = json["deleted_at"].intValue
      self.subject.onNext(ChatroomEvents.messageDeleted(
        messageId: messageId,
        userId: deletedBy,
        deletedAt: deletedAt))
    }
    
    self.channel.on("user:warned") { response in
      let json = response.payload as [String : Any]
      let fromId = json["from"] as! String
      let memberId = json["member_id"] as! String
      let reason = json["reason"] as! String
      self.subject
        .onNext(ChatroomEvents.userWarned(fromId: fromId, memberId: memberId, reason: reason))
    }
    
    self.channel.on("user:banned") { response in
      let json = response.payload as [String : Any]
      let fromId = json["from"] as! String
      let memberId = json["member_id"] as! String
      let reason = json["reason"] as! String
      self.subject
        .onNext(ChatroomEvents.userBanned(fromId: fromId, memberId: memberId, reason: reason))
    }
    
    self.channel.on("user:role_updated") { response in
      let json = response.payload as [String : Any]
      let fromId = json["from"] as! String
      let memberId = json["member_id"] as! String
      let role = json["role"] as! String
      self.subject
        .onNext(ChatroomEvents.userRoleUpdated(fromId: fromId, memberId: memberId, role: role))
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // Joining Channel
    
    self.channel.join()!
      .receive("ok") { (json) in
        print(json)
        var messages = [MessageDto]()
        let jsonRoot = json as [String : AnyObject]
        if let datas = jsonRoot["response"]!["messages"] as? [AnyObject] {
          for data in datas {
            print(json)
            let jsonMessage = JSON(data)
            var userMessage = UserMessageDto(json: jsonMessage)
            userMessage.isOwn = userMessage.authorId == uid
            let message = MessageDto(json: jsonMessage, type: .userMessage(message: userMessage))
            messages.append(message)
          }
        }
        
        if let infos = jsonRoot["response"] as? [String : Any] {
          let jsonInfos = JSON(infos)
          let chatroomInfos = MessagingInfos.chatroom(ChatroomDTO(jsonChatroom: jsonInfos))
          self.subject.onNext(.load(messages: messages, infos: chatroomInfos))
        }
      }
      .receive("error") { (error) in
        print("ERROR", error)
        if let response = error["response"] as? [String:String] {
          switch response["reason"]! {
          case "Banned":
            print("api - join failed: banned")
            self.subject.onNext(.error(CastrError.banned))
          default:
            self.subject.onError(CastrError.undefined)
          }
        }
        else {
          self.subject.onError(CastrError.undefined)
        }
    }
  }
  
  func toObservable() -> Observable<ChatroomEvents> {
    return subject.asObservable()
  }
  
  func leave(){
    self.channel.leave()
    print("chatroom api - chatroom leaved")
  }
  
  // Message Incoming Events
  
  func deleteMessage(messageId: String) -> Observable<Void>{
    print("Id!", self.id )
    return Observable.create{ emitter in
      self.channel.send("message:delete", payload: ["message_id": messageId])!
        .receive("ok", callback: { (payload) in
          print("Payload ! ", payload, "Id ! ", self.id )
          emitter.onNext()
        })
        .receive("error", callback: { (_) in
          emitter.onError(SocketError.cantConnect)
        })
      return Disposables.create()
    }
  }
  
  func sendMessage(text: String) -> Observable<UserMessageDto> {
    return Observable.create { emitter in
      self.channel.send("message:send", payload: ["text": text])!
        .receive("ok") { (payload) in
          
          if let response = payload["response"] {
            let jsonMessage = JSON(response)
            let message = UserMessageDto(json: jsonMessage)
            print("MESSAGE SEND RETURN", payload)
            emitter.onNext(message)
          }
        }
        .receive("error") { (error) in
          
      }
      return Disposables.create()
    }
  }
  
  func sendMessageWithData(url: String, msgId: String, imageData: Data, text: String?, quoteIds: [String?]) -> Observable<UserMessageDto> {
    
    print("sending image infos to API")
    
    let image = UIImage(data: imageData)
    let messageData : [String:Any] = ["download_url": url,
                                      "message_id": msgId,
                                      "text": text ?? "",
                                      "content_type": "image/jpeg",
                                      "byte_size": Int(imageData.count),
                                      "width": Int(image!.size.width),
                                      "height" : Int(image!.size.width)
                                     ]
    
    return Observable.create { emitter in
      self.channel.send("message:send_uploaded_media", payload: messageData)!
        .receive("ok") { (payload) in
          let jsonMessage = JSON(payload)
          let message = UserMessageDto(json: jsonMessage)
          emitter.onNext(message)
        }
        .receive("error") { (error) in
          emitter.onError(CastrError.undefined)
      }
      return Disposables.create()
    }
  }
  
  func sendLove(messageId: String, lovesAmount: Int) -> Observable<String> {
    return Observable.create{ emitter in
      self.channel
        .send("message:love", payload: ["message_id": messageId, "love": lovesAmount])!
        .receive("ok", callback: { (_) in
          print("\(lovesAmount) loves emitted")
          emitter.onNext("\(lovesAmount) loves emitted")
        })
        .receive("error", callback: { (_) in
          print("error emitted")
          emitter.onNext("error with loves")
        })
      return Disposables.create()
    }
  }
  
  func requestMessagePage(fromMessageId: String, uId: String) -> Observable<[MessageDto]> {
    print("chatroom api - request page")
    return Observable.create{ emitter in
      self.channel
        .send("message:request_page", payload: ["from_id": fromMessageId])!
        .receive("ok", callback: { (json) in
          print("chatroom api - request page sucess")
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
        .receive("error", callback: { (error) in
//          emitter.onError(.socketError)
        })
      return Disposables.create()
    }
  }
  
}

