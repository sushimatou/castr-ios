//
//  MessageModalPresenter.swift
//  CastrApp
//
//  Created by Antoine on 14/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class MessageModalPresenter {
    
    // MARK : - Properties
    
    static let instance = MessageModalPresenter()
    let interactor = ChatroomInteractor()
    let initState = MessageModalViewState()
    var view = MessageModalViewController()
    var disposable: Disposable?
    
    // MARK : - Binding View
    
    func bind(view : MessageModalViewController) {
        self.view = view
        self.disposable = Observable
            .merge([obsUid(),
                    obsDeleteMessageIntent()])
            .scan(initState, accumulator: reduceViewState)
            .subscribe(onNext: { (result) in
                view.render(state: result)
            })
        
    }
    
    // MARK : - Observables
    
    private func obsDeleteMessageIntent() -> Observable<MessageModalAction> {
        return view
            .deleteMessageIntent()
            .flatMap{ _ in
                return self.interactor.deleteMessage(
                    chatroomId: self.view.chatroomId,
                    messageId: self.view.message.msgId)
            }
            .map{ result in
                switch result {
                case .success():
                    return MessageModalAction.setDeleted
                case .failed(_):
                    return MessageModalAction.undefined
                }
            }
    }
    
    private func obsUid() -> Observable<MessageModalAction> {
        return interactor.getUid().map{ uid in
            return MessageModalAction.setUid(uid: uid)
        }
    }

    private func reduceViewState(previousState: MessageModalViewState, changes: MessageModalAction) -> MessageModalViewState{
        
        let newState = previousState
        
        switch changes {
            
        case .undefined:
            return newState
        case .setUid(let uid):
            newState.userId = uid
            return newState
        case .setDeleted:
            newState.deleted = true
            return newState
            
        }
    }
    
    // MARK : - Unbinding View
    
    func unbind(view : MessageModalViewController) {
        self.disposable?.dispose()
    }
    
    // MARK : - Reducing View State
    
    func reduceViewState() {
        
    }
    
    
}
