//
//  DiscoveryAction.swift
//  CastrApp
//
//  Created by Castr on 07/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
enum DiscoveryAction {
  case setLoadingMoreState(state: Bool)
  case fetchChatroomList(chatroomList: [ChatroomDTO])
  case fetchMoreChatrooms(chatroomList: [ChatroomDTO])
  case error(CastrError)
  case undefined
}
