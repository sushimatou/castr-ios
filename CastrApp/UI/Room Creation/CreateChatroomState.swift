//
//  CreateChatroomState.swift
//  CastrApp
//
//  Created by Antoine on 25/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct CreateChatroomState {
    
    var isLoading: Bool
    var isEnabled: Bool
    var createdId: String?
    var chatroomResults : [SearchResultsDto] = []
    
    var chatroomNameState: FieldState? = .pristine
    
    init (isEnabled: Bool, isLoading: Bool) {
        self.isLoading = isLoading
        self.isEnabled = isEnabled
    }
  
}
