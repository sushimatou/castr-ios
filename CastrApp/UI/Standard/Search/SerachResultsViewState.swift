//
//  SerachResultsViewState.swift
//  CastrApp
//
//  Created by Antoine on 27/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct SearchResultsViewState {
    
    var isLoading: Bool
    var resultsByAutocomplete : [SearchResultsDto]
    var resultsBySearch: [SearchResultsDto]
    
    init() {
        isLoading = true
        resultsByAutocomplete = []
        resultsBySearch = []
    }
    
}
