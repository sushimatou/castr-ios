//
//  DiscoveryViewState.swift
//  CastrApp
//
//  Created by Castr on 07/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct DiscoveryViewState {
  
  var isLoading: Bool = true
  var isLoadingMore: Bool = false
  var isAtBottom: Bool = false
  var chatroomList: [ChatroomDTO] = []
  var error: CastrError? = nil
  
}
