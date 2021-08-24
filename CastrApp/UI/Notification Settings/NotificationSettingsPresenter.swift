//
//  NotificationPresenter.swift
//  CastrApp
//
//  Created by Antoine on 04/12/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class NotificationSettingsPresenter {
    
    // MARK: - Properties
    
    static let instance = NotificationSettingsPresenter()
    private let service = UserService.instance
    private var view = NotificationSettingsTableViewController()
    private var disposable: Disposable?
    
    // MARK: - Bind/Unbind Funcs
    
    public func bind(viewController: NotificationSettingsTableViewController){
        self.view = viewController
    }
    
    public func unbind(){
        self.disposable?.dispose()
    }
    
    // MARK: - Observables
    
//    private func obsAllNotificationsIntent() -> Observable<NotificationSettingsAction> {
//        return self
//            .view
//            .allNotificationIntent()
//            .flatMap{ value in
//                return self.service.updateNotificationSettings(setting: "disabled", value: !value)
//            }
//            .map{ result in
//                switch result {
//                case .success:
//                    return 
//                case .failed(let error):
//                    return 
//                }
//            }
//    }
    
    // MARK: - Reduce View State
    
    private func reduceViewState(previousState: NotificationSettingsViewState, action: NotificationSettingsAction) -> NotificationSettingsViewState {
        return previousState
    }
    
}
