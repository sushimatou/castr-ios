//
//  AppDelegate.swift
//  CastrApp
//
//  Created by Castr on 19/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UserNotifications
import UIKit
import Firebase
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
  
  let manager = NetworkReachabilityManager(host: "castr.com")
  let userService = UserService.instance
  let feedService = FeedService.instance
  let toast = ToastView.loadFromXib()
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    manager?.listener = { status in
      switch status {
      case .reachable(_):
        self.toast?.dismiss()
      case .notReachable:
        self.toast?.show(viewController: (self.window?.visibleViewController)!)
      case .unknown:
        self.toast?.show(viewController: (self.window?.visibleViewController)!)
      }
    }
    
    #if PREPROD
      let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
    #else
      let filePath = Bundle.main.path(forResource: "GoogleService-Info-AppStore", ofType: "plist")
    #endif
    
    let fileopts = FirebaseOptions.init(contentsOfFile: filePath!)
    UITabBar.appearance().tintColor = .white
    UINavigationBar.appearance().tintColor = .white
    FirebaseApp.configure(options: fileopts!)
    FirebaseAuth.start()
    Messaging.messaging().delegate = self
    userService.start()
    feedService.start()
    application.registerForRemoteNotifications()
    connectToAPNS(application: application)
    manager?.startListening()
    return true
  }
  
  func connectToAPNS(application: UIApplication) {
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: {_, _ in })
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    userService.start()
    feedService.start()
    manager?.startListening()
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    userService.start()
    feedService.start()
    FirebaseAuth.start()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    userService.stop()
    feedService.stop()
    manager?.stopListening()
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print(userInfo)
  }
  
}

