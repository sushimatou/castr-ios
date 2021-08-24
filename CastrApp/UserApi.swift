//
//  UserApi.swift
//  CastrApp
//
//  Created by Antoine on 30/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import Birdsong
import SwiftyJSON
import RxSwift

class UserApi {
  
  // MARK: - Properties
  private let channel: Channel
  private let subject = PublishSubject<UserEvent>()
  let uid : String
  
  init(socket: Socket, uid: String) {
    self.uid = uid
    self.channel = socket.channel("profile:\(uid)")
    
    self.channel.on("blacklist:added") { (response) in
      if let json = response.payload as? [String : Int] {
        let json = JSON(json)
        let blacklistedId = json["blacklisted_id"].stringValue
        self.subject.onNext(.addUserToBlackList(blacklistedUserId: blacklistedId))
      }
    }
    
    self.channel.on("blacklist:removed") { (response) in
      if let json = response.payload as? [String : Int] {
        let json = JSON(json)
        let blacklistedId = json["blacklisted_id"].stringValue
        self.subject.onNext(UserEvent.removeUserFromBlacklist(blacklistedUserId: blacklistedId))
      }
    }
    
    self.channel.on("stats:updated") { (response) in
      if let json = response.payload as? [String : Int] {
        let json = JSON(json)
        let loves = json["love"].int
        let messages = json["messages"].int
        self.subject.onNext(.statsUpdated(stats: (loves: loves, messages: messages)))
      }
    }
    
    self.channel.on("profile:updated") { (response) in
      print("user api - profile updated - response:", response)
      let json = JSON(response.payload)
      self.subject.onNext(.profileUpdated(
        name: json["updates"]["name"].string,
        color: json["updates"]["color"].int,
        isRegistered: json["updates"]["is_registered"].bool,
        picture: json["updates"]["picture"]["uri"].string))
    }
  }
  
  func join() -> Observable<UserEvent> {
    return Observable.create({ (emitter) -> Disposable in
      print("DebugSocket", "UserApi - join")
      self.channel.join()!
        .receive("ok"){ (response) in
          print("user api - user joigned", response)
          let json = response as [String : AnyObject]
          if let jsonRoot = json["response"] as? [String : AnyObject] {
            let jsonUser = JSON(jsonRoot)
            let user = UserDTO(json: jsonUser)
            emitter.onNext(.profileLoaded(user: user))
          }
          emitter.onCompleted()
        }
        .receive("error") { (error) in
          print("user api - user can't joigned")
          print(error)
          emitter.onCompleted()
      }
      return Disposables.create()
    })
  }
  
  func observeEvents() -> Observable<UserEvent> {
    return self.subject.asObservable()
  }
  
  func generateColor() -> Observable<Void> {
    
    return Observable.create{ emitter in
      self.channel
        .send("profile:generate_color", payload: ["":""])!
        .receive("error", callback: { (_) in
          emitter.onNext()
        })
      return Disposables.create()
    }
    
  }
  
  func generateName() -> Single<(adj: String, noun: String)> {
    
    return Single.create{ emitter in
      self.channel
        .send("profile:generate_name", payload: [:])!
        .receive("ok", callback: { (response) in
          let json = JSON(response)
          let adj = json["response"]["name"]["adj"].stringValue
          let noun = json["response"]["name"]["noun"].stringValue
          emitter(.success((adj: adj, noun: noun)))
        })
        .receive("error", callback: { (error) in
          emitter(.error(CastrError.cantGenerateName))
        })
      return Disposables.create()
    }
  }
  
}

