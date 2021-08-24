//
//  CreateChatroomAction.swift
//  CastrApp
//
//  Created by Antoine on 25/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum CreateChatroomAction {
    
    case setIsLoading(isLoading: Bool)
    case setIsEnabled(isEnabled: Bool)
    case setNameFieldState(state: FieldState)
    case resultsChatrooms(results: [SearchResultsDto])
    case setCreatedId(createdId: String)
    case undefined
    
}
