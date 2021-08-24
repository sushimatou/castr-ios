//
//  SocketApi.swift
//  CastrApp
//
//  Created by Antoine on 29/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import Birdsong
import RxSwift

class SocketApi {
  
  //MARK: - Properties
  
  private static var instance = SocketApi()
  static func getInstance() -> SocketApi {
    return instance
  }
  
  private let instancesSubject = PublishSubject<(String, Socket)>()
  private var socket : Socket?
  private var uid : String?
  private var token : String?
  
  // API
  private var user : UserApi?
  private var feed : FeedApi?
  private var chat : ChatApi?
  private var chatroom : ChatroomApi?
  
  // MARK: - Token Initialization
  
  private init() {}
  
  func connect(uid: String, token: String) {
    
    if token == self.token {
      return
    }
    
    let socket = Socket(prot: "ws",
                         host: Config.wsEndPoint,
                         path: "socket",
                         transport: "websocket",
                         params: ["token_id": token])
    
    self.uid = uid
    self.token = token
    self.socket = socket
    
    socket.onConnect = {
      self.instancesSubject.onNext((uid, socket))
    }
    
    socket.onDisconnect = { error in
      if error != nil {
        // self.instancesSubject.onError(SocketError.cantConnect)
      }
    }
    
    socket.connect()
  }
  
  func observeInstance() -> Observable<(String, Socket)> {
    if (uid != nil && socket != nil) {
      print("SocketApi.observeInstance - not nil")
      return Observable.concat(Observable.of((uid!, socket!)), instancesSubject.asObservable())
    }
    else {
      return instancesSubject.asObservable()
    }
  }
  
  // MARK: - Chatroom Funcs
  
  func getChatroom(chatroomId: String) -> Observable<ChatroomApi> {
    return observeInstance()
      .map({ (uid, socket) -> ChatroomApi in
        self.getChatroomApi(socket: socket, uid: uid, chatroomId: chatroomId)
      })
  }
  
  private func getChatroomApi(socket: Socket, uid: String, chatroomId: String) -> ChatroomApi {
    if self.chatroom == nil || (self.chatroom != nil && self.chatroom!.id != chatroomId) {
      // TODO Should leave the channel here?
      self.chatroom = ChatroomApi(socket: socket, id: chatroomId, uid: uid)
    }
    return self.chatroom!
  }
  
  func leaveChatroom(chatroomId: String) {
    if chatroom != nil {
      self.chatroom!.leave()
      self.chatroom = nil
    }
  }
  
  // MARK: - Chat Funcs
  
  func getChat(chatId: String) -> Observable<ChatApi> {
    return observeInstance()
      .map({ (uid, socket) -> ChatApi in
        return self.getChatApi(socket: socket, uid: uid, chatId: chatId)
      })
  }
  
  private func getChatApi(socket: Socket, uid: String, chatId: String) -> ChatApi {
    if self.chat == nil || (self.chat != nil && self.chat!.id != chatId) {
      // TODO Should leave the channel here?
      self.chat = ChatApi(socket: socket, id: chatId, uid: uid)
    }
    return self.chat!
  }
  
  func leaveChat(chatId: String) {
    if chat != nil {
      self.chat!.leave()
      self.chat = nil
    }
  }
  
  // MARK: - User Funcs

  func getUser() -> Observable<UserApi> {
    return observeInstance()
      .map({ (uid, socket) -> UserApi in
        print("DebugSocket", "SocketApi - getUser - map", uid)
        return self.getUserApi(socket: socket, uid: uid)
      })
  }
  
  private func getUserApi(socket: Socket, uid: String) -> UserApi {
    
    if self.user == nil || (self.user != nil && self.user!.uid != uid) {
      print("DebugSocket", "SocketApi - getUserApi - NIL")
      self.user = UserApi(socket: socket, uid: uid)
    }
    return self.user!
  }
  
  // MARK: - Feed Func
  
  func getFeed() -> Observable<FeedApi> {
    return observeInstance()
      .map({ (uid, socket) -> FeedApi in
        self.getFeedApi(socket: socket, uid: uid)
      })
  }
  
  private func getFeedApi(socket: Socket, uid: String) -> FeedApi {
    if self.feed == nil || (self.feed != nil && self.feed!.uid != uid) {
      self.feed = FeedApi(socket: socket, uid: uid)
    }
    return self.feed!
  }
}

