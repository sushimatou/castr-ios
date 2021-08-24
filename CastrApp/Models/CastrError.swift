//
//  CastrError.swift
//  CastrApp
//
//  Created by Antoine on 10/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

public enum CastrError : String, Error {
  
  // Generics
  
  case timeOut
  case unauthorized
  case busyService
  
  
  // Sign In / Sign up

  case invalidMail
  case invalidUsername
  case invalidPassword
  case mailAlreadyExists
  case credentialsAlreadyExists
  case nameAlreadyExists
  case userDisabled
  case cantChangeUsername
  case cantGenerateName
  
  // Chatroom
  
  case accessDenied
  case banned
  case chatroomNotFound
  case cantReport
  
  // Room Creation
  
  case invalidChatroomName
  
  // Medias
  
  case unsupportedFormat
  case fileTooLarge
  
  // Feed
  
  case cantDelete
  
  // Others
  
  case cantRemoveFromBlackList
  case canAddToBlackList
  case userNotFound
  case cantChangeSettings
  case undefined
  
}
