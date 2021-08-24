//
//  ChatInteractor.swift
//  CastrApp
//
//  Created by Antoine on 13/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class ChatInteractor : MessagingInteractorProtocol {
  
  func load(contextId: String) -> Observable<Result<(messages: [MessageDto], infos: MessagingInfos)>> {
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .flatMap{ uid in
        return DataChatMessages
          .getChatEvents(chatId: contextId, uid: uid)
          .filter{ event in
            if case .load(_,_) = event { return true }
            else{ return false }
          }
          .map{ event in
            var userMessages: [MessageDto] = []
            var chatInfos: MessagingInfos!
            if case .load(let messages, let infos ) = event {
              userMessages = messages
              chatInfos = infos
            }
            return Result.success(userMessages, chatInfos)
        }
      }
      .catchError{ error in
        return Observable.just(Result.failed(error: CastrError.undefined))
    }
  }
  
  func loadMoreMessages(contextId: String, fromMessageId: String) -> Observable<[MessageDto]> {
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .flatMap{ uid in
        return DataChatMessages
          .getMoreMessages(chatId: contextId,
                           uid: uid,
                           fromMessageId: fromMessageId)
    }
  }
  
  func receiveNewMessage(contextId: String) -> Observable<MessageDto?> {
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .flatMap{ uid in
      return DataChatMessages
        .getChatEvents(chatId: contextId, uid: uid)
        .filter{ event in
          if case .messageSent(message: _) = event { return true }
          else{ return false }
        }
        .map{ event in
          if case .messageSent(let message) = event {
            return message
          }
          else { return nil }
      }
    }
  }
  
  func sendMessage(contextId: String, text: String, quotesIds: [String]?) -> Observable<Result<(message: UserMessageDto, localId: String)>> {
    return FirebaseAuth
      .getAuthUser()
      .flatMap({ (uid) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
        return UserService
          .instance
          .toObservable()
          .take(1)
          .flatMap({ (profile) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
            let localMsgId = DataChatMessages.genMessageId(chatId: contextId)
            print("chat - interactor - create message - localId:", localMsgId)
            let createdMessage = UserMessageDto(type: .text(text: text),
                                                profile: profile,
                                                id: localMsgId,
                                                status: .sending,
                                                isOwn: true)
            
            let createdObs = Observable.just((message: createdMessage, localId: localMsgId))
            let sentObs = DataChatMessages
              .sendMessage(chatId: contextId, message: text, uid: uid)
              .flatMap({ (message) -> Observable<(message: UserMessageDto, localId: String)> in
                print("chat - interactor - send message - localId:", localMsgId, "messageId:", message.msgId)
                var message = message
                message.isOwn = true
                message.status = .sent
                return Observable.just((message: message, localId: localMsgId))
              })
            
            return Observable.merge([createdObs, sentObs])
              .flatMap({ (messageTuple) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
                print("chat - interactor - obs sending emits - localId:", localMsgId)
                return Observable.just(Result.success(messageTuple))
              })
          })
      })
      .catchError{ error in
        return Observable.just(Result.failed(error: CastrError.undefined))
    }
  }
  
  func sendMediaMessage(contextId: String, imageData: Data, text: String?, quotesIds: [String?]) -> Observable<Result<(message: UserMessageDto, localId: String)>> {
    return FirebaseAuth
      .getAuthUser()
      .flatMap({ (uid) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
        return UserService
          .instance
          .toObservable()
          .take(1)
          .flatMap({ (profile) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
  
            let image = UIImage(data: imageData)
            let createdId = DataChatroomMessages.genMessageId(chatroomId: contextId)
            var createdMessage = UserMessageDto(type: .media(mediaWith: .image(image!), format: .jpeg, text: text),
                                                profile: profile,
                                                id: createdId,
                                                status: .sending,
                                                isOwn: true)
          
            let createObs = Observable.just((message: createdMessage, localId: createdId))
            
            let uploadObs = FirebaseDatabase.uploadImageToDatabase(context: .uploadMessageChat(chatId: contextId), imageData: imageData)
                .flatMap({ (uploadStatus) -> Observable<(message: UserMessageDto, localId: String)> in
                  switch uploadStatus {
                  case .uploading(let progression):
                    createdMessage.status = .uploading(progression: progression)
                    return Observable.just((message: createdMessage, localId: createdId))
                    
                  case .uploaded(let url):
                    return DataChatroomMessages
                      .sendImageMessage(chatroomId: contextId,
                                        text: text,
                                        imageData: imageData,
                                        uid: uid,
                                        url: url.absoluteString,
                                        msgId: createdId,
                                        quotesIds: quotesIds)
                      .flatMap({ (message) -> Observable<(message: UserMessageDto, localId: String)> in
                        var message = message
                        message.status = .sent
                        return Observable.just((message: message, localId: createdId))
                      })
                  }
                })
            
            return Observable.merge([createObs, uploadObs])
              .flatMap({ (messageTuple) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
                return Observable.just(Result.success(messageTuple))
              })
            
          })
          .catchError{ error in
            return Observable.just(Result.failed(error: CastrError.undefined))
        }
      })
  }
  
  func leave(contextId: String){
    DataChatMessages.leave(chatId: contextId)
  }
}


