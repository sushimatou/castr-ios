
//
//  ProfileViewState.swift
//  CastrApp
//
//  Created by Castr on 22/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//
//

enum ProfileViewState {
  
  case isLoading
  case error(error: CastrError)
  case profile(user: UserDTO)
  
}

