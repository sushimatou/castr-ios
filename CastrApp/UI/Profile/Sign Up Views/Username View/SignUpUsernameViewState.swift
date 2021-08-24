//
//  SignUpUsernameViewState.swift
//  CastrApp
//
//  Created by Antoine on 05/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct SignUpUsernameViewState {
    var isConnected = false
    var isEnabled = false
    var error: CastrError?
    var username: FieldState? = .pristine
}
