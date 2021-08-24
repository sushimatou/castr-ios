//
//  ChatroomState.swift
//  CastrApp
//
//  Created by Antoine on 19/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

struct MessagingViewState {
  
  // MARK: - Properties
  
  var isLoading = true
  var isLoadingMore = false
  var isAtTop = false
  var isNewPage = false
  var canLoadMore = false
  var shouldScrollToBottom = true
  var isSendingMsg = false
  
  var messages = [MessageDto]()
  var groupedMessages = [String : [MessageDto]]()
  var datesSections = [String]()
  
  var infos : MessagingInfos?
  var profile: UserDTO?
  var media: UIImage? = nil
  var reported: Bool?
  var blocked: Bool?
  var unblocked: Bool? 
  var error: CastrError?
  
}
