//
//  MessagingSorting.swift
//  CastrApp
//
//  Created by Antoine on 08/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

class MessagingSorting {
  
  static func createDateSectionsListByMessages(messages: [MessageDto]) -> [String] {
    var dateSections = [String]()
    for message in messages {
      let dateStr = DateHelper.getStringFromDate(date: message.createdAt)
      var sameDate: Bool = false
      for date in dateSections {
        if date == dateStr {
          sameDate = true
          break
        }
      }
      if !sameDate {
        dateSections.append(dateStr)
      }
    }
    return dateSections
  }
  
  static func groupMessagesByDateSections(datesSections: [String], messages: [MessageDto]) -> [String:[MessageDto]] {
    
    var messageGroups = [String:[MessageDto]]()
    
    for dateSection in datesSections {
      var messageGroup = [MessageDto]()
      for message in messages {
        let dateStr = DateHelper.getStringFromDate(date: message.createdAt)
        if dateStr == dateSection {
          messageGroup.append(message)
        }
      }
      messageGroups[dateSection] = messageGroup
    }
    return messageGroups
  }
}
