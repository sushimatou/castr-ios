//
//  ChangeNameViewState.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum ChangeNameViewState {
    case loading
    case empty
    case editing(nameFieldState: FieldState)
    case error(_: CastrError)
    case changeNameDone
}
