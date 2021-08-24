//
//  ProfileAction.swift
//  CastrApp
//
//  Created by Castr on 04/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum ProfileAction {

    case setLoading
    case setError(CastrError)
    case setProfile(UserDTO)
    
    case updateName(String)
    case updateColor(Int)
    case updateLove(Int)
    case updateMessage(Int)
    case updatePicture(String)
    
    case undefined
    
}
