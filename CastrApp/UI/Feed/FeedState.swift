//
//  FeedState.swift
//  CastrApp
//
//  Created by Antoine on 04/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

struct FeedState {
  
  var isLoading = false
  var isLoadingMore = false
  var isEmpty = false
  var isAtBottom = false
  var feedElements = [FeedElement]()
  var error: CastrError?
  
}
