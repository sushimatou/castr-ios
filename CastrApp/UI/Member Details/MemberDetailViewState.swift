//
//  MemberDetailViewState.swift
//  CastrApp
//
//  Created by Antoine on 19/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct MemberDetailViewState {
    
    var isLoading = false
    var memberDetails: MemberDetailDto?
    var isBanned: Bool?
    var error: CastrError?
}
