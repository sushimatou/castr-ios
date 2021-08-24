//
//  SearchAction.swift
//  CastrApp
//
//  Created by Antoine on 27/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum SearchAction {
    case setLoading(loading: Bool)
    case autcomplete(chatrooms: [SearchResultsDto])
    case search(chatrooms: [SearchResultsDto])
}
