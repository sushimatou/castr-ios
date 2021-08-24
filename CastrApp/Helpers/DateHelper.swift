//
//  DateFormatHelper.swift
//  CastrApp
//
//  Created by Antoine on 20/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

class DateHelper {
    
    static func HoursWithTimestamp(timestamp: Double) -> String {
        
        let date = Date(timeIntervalSince1970: timestamp)
        let hoursFormatter = DateFormatter()
        hoursFormatter.dateFormat = "HH:mm"
        return hoursFormatter.string(from: date)

    }
    
    static func getStringFromDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "fr_FR")
        var dateString = ""
        
        let today = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: today)
        
        let days =  components.day!
        let hours =  components.hour!
        let minutes =  components.minute!
        let seconds = components.second!
        
//        print("\(days) days \(hours) hours \(minutes) minutes \(seconds) seconds")
        
        if days > 7 {
            dateString = dateFormatter.string(from: date)
        }
        
        else if days == 7 {
            dateString = "il y a une semaine"
        }
        
        else if days <= 6 && days > 1 {
            dateString = "Il y a \(days) jours "
        }
        
        else if days == 1 {
            dateString = "Hier"
        }
        
        else if hours < 24 && hours > 1 {
            dateString = "Il y a \(hours) heures"
        }
        
        else if hours == 1 {
            dateString = "Il y a une heure"
        }
        
        else if minutes < 59 && minutes > 1 {
            dateString = "Il y a \(minutes) minutes"
        }
        
        else if minutes == 1 {
            dateString = "Il y a une minute"
        }
        
        else if seconds < 59 && seconds > 20 {
            dateString = "Il y a moins d'une minute"
        }
        
        else {
            dateString = "Maintenant"
        }
        return dateString
    }
    
    static func getTimeFromNow(interval: Double) -> String {
        
        let currentTime = Date()
        let messageTime = Date(timeIntervalSince1970: interval/1000)
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        return (formatter.string(from: messageTime, to: currentTime)?.uppercased())!

    }

    static var timestamp: Double {
        return Date().timeIntervalSince1970 
    }
    
    
    
    
}
