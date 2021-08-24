//
//  ChatroomSettingsAction.swift
//  CastrApp
//
//  Created by Antoine on 04/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum ChatroomSettingsAction {
    
    case changeColor(color: Int)
    case setNameState(state: FieldState)
    case setDescriptionState(state: FieldState)
    case updatesOk
    case undefined
    
}
