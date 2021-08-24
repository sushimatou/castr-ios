//
//  NotificationApi.swift
//  CastrApp
//
//  Created by Antoine on 04/12/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift
import Birdsong

class NotificationApi {
  
  // MARK: - Properties
  private let channel: Channel
  private let subject = PublishSubject<NotificationEvent>()
  let uid : String
  
  init(socket: Socket, uid: String) {
    self.uid = uid
    self.channel = socket.channel("profile:\(uid)")
  }
}
