//
//  ChatroomInfosViewState.swift
//  CastrApp
//
//  Created by Antoine on 28/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct ChatroomInfosViewState {
  var isLoading = false
  var infos : ChatroomDTO?
  var admins = [UserDTO]()
  var moderators = [UserDTO]()
}
