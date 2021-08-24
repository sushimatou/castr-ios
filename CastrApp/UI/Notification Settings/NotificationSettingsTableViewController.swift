//
//  NotificationSettingsTableViewController.swift
//  CastrApp
//
//  Created by Antoine on 04/12/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift

class NotificationSettingsTableViewController: UITableViewController {
    
    // --------------------------------------------------------------------------------
    
    // MARK: - IBOutlets & Properties
    
    @IBOutlet weak var allNotificationsSwitch: UISwitch!
    @IBOutlet weak var privateMessageSwitch: UISwitch!
    @IBOutlet weak var channelQuotedSwitch: UISwitch!
    @IBOutlet weak var messageLovedSwitch: UISwitch!
    @IBOutlet weak var channelInvite: UISwitch!
    @IBOutlet weak var channelBanSwitch: UISwitch!
    @IBOutlet weak var channelWarnSwitch: UISwitch!
    @IBOutlet weak var channelActivitySwitch: UISwitch!
    @IBOutlet weak var newFeatureSwitch: UISwitch!
    
    // public let notificationSetSubject = PublishSubject<(set: String, value: Bool)
    
    // --------------------------------------------------------------------------------

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.headerView(forSection: 1)?.tintColor = .castrGreen
        tableView.headerView(forSection: 2)?.textLabel?.textColor = .castrPink
        tableView.headerView(forSection: 3)?.textLabel?.textColor = .castrBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationSettingsPresenter.instance.bind(viewController: self)
    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: - Render
    
    func render(state: NotificationSettingsViewState){
        
    }
    
    // --------------------------------------------------------------------------------
    
    // MARK: - Intents
    
    func allNotificationIntent() -> Observable<Bool> {
        return self
            .allNotificationsSwitch
            .rx
            .isOn
            .asObservable()
    }
    
    func privateMessageIntent() -> Observable<Bool> {
        return self
            .privateMessageSwitch
            .rx
            .isOn
            .asObservable()
    }
    
    func channelQuotedIntent() -> Observable<Bool> {
        return self
            .channelQuotedSwitch
            .rx
            .isOn
            .asObservable()
    }
    
    func messageLovedIntent() -> Observable<Bool> {
        return self
            .messageLovedSwitch
            .rx
            .isOn
            .asObservable()
    }
    
    func channelInviteIntent() -> Observable<Bool> {
        return self
            .channelInvite
            .rx
            .isOn
            .asObservable()
    }
    
    func channelBanIntent() -> Observable<Bool> {
        return self
            .channelBanSwitch
            .rx
            .isOn
            .asObservable()
    }
    
    func channelWarnIntent() -> Observable<Bool> {
        return self
            .channelWarnSwitch
            .rx
            .isOn
            .asObservable()
    }
    
    func channelActivityIntent() -> Observable<Bool> {
        return self
            .channelActivitySwitch
            .rx
            .isOn
            .asObservable()
    }
    
    func newFeatureIntent() -> Observable<Bool> {
        return self
            .newFeatureSwitch
            .rx
            .isOn
            .asObservable()
    }
    
}
