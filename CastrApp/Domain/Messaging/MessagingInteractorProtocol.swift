//
//  MessagingInteractor.swift
//  CastrApp
//
//  Created by Antoine on 13/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

protocol MessagingInteractorProtocol {
    
    func load(contextId: String) -> Observable<Result<(messages: [MessageDto], infos: MessagingInfos)>>
    
    func loadMoreMessages(contextId: String, fromMessageId: String) -> Observable<[MessageDto]>
    
    func receiveNewMessage(contextId: String) -> Observable<MessageDto?>
    
    func sendMessage(contextId: String, text: String, quotesIds: [String]?) -> Observable<Result<(message: UserMessageDto, localId: String)>>
    
    func sendMediaMessage(contextId: String, imageData: Data, text:String? ,quotesIds: [String?]) -> Observable<Result<(message: UserMessageDto, localId: String)>>
    
    func leave(contextId: String)
    
}
