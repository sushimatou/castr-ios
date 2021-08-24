//
//  FeedAction.swift
//  CastrApp
//
//  Created by Antoine on 04/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

enum FeedAction {
    case fetchFeedElements([FeedElement])
    case fetchMoreFeedElements([FeedElement])
    case deleteFeedElement(FeedElement)
    case setLoadMoreState(Bool)
    case setError(CastrError)
    case undefined
}
