//
//  ChatroomSettingsViewState.swift
//  CastrApp
//
//  Created by Antoine on 04/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct ChatroomSettingsViewState {
    
    var initName: String?
    var initDescription: String?
    var nameState: FieldState = .pristine
    var descriptionState: FieldState = .pristine
    var color: Int?
    var closed: Bool = false
    
}
