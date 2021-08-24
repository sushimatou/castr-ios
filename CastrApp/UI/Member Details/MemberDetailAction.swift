//
//  MemberDetailAction.swift
//  CastrApp
//
//  Created by Antoine on 19/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum MemberDetailAction {
    
    case loadMemberDetail(_: MemberDetailDto)
    case changeMemberRole(Role)
    case banMember
    case showError(_: CastrError)
    case undefined
    
}
