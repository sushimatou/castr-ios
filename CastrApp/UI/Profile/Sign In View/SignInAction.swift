//
//  SignInAction.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum SignInAction {

    case changeMailTxtFieldState(_: FieldState)
    case changePwdTxtFieldState(_: FieldState)
    case changeViewState(_: SignInViewState)
}
