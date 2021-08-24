//
//  NotificationViewController.swift
//  MessagingNotification
//
//  Created by Antoine on 30/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView {
        get {
            return inputView!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        switch response.actionIdentifier {
        case "voir":
            break // noop
        case "repondre":
            self.becomeFirstResponder()
        default:
            break
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body

    }

}
