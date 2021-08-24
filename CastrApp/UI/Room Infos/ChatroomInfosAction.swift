//
//  ChatroomInfosAction.swift
//  CastrApp
//
//  Created by Antoine on 28/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum ChatroomInfosAction {
  case undefined
  case setAdmins([UserDTO])
  case setModos([UserDTO])
}
