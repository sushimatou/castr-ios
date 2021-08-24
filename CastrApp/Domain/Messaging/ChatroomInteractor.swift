//
//  ChatroomInteractor.swift
//  CastrApp
//
//  Created by Antoine on 18/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class ChatroomInteractor : MessagingInteractorProtocol {
  
  
  let castrBotSubject = PublishSubject<MessageDto>()
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK: - CastrBot Methods
  
  func loadCastrBotMessages() -> Observable<MessageDto> {
    var delay = 0.0
    return castrBotSubject
      .flatMap({ (message) -> Observable<MessageDto> in
        delay += 0.8
        return Observable.just(message).delay(delay, scheduler: MainScheduler.instance)
      })
  }

  func generateCastrBotMessage() {
    
    let createdMessage = MessageDto(id: "0", type: .botMessage(type: .text("Et voilà, votre chatroom est crée !")))
    self.castrBotSubject.onNext(createdMessage)
    
    let settingsMessage = MessageDto(id: "1", type: .botMessage(type: .text("Vous pouvez la configurer dès maintenant à l'aide du bouton vert en haut à droite, ou commencer à parler !")))
    self.castrBotSubject.onNext(settingsMessage)
    self.castrBotSubject.onCompleted()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  //MARK: - Message Methods
  
  func load(contextId: String) -> Observable<Result<(messages: [MessageDto], infos: MessagingInfos)>> {
    return FirebaseAuth.getAuthUser().flatMap{uid in
      return DataChatroomMessages
        .getChatroomEvents(chatroomId: contextId, uid: uid)
        .filter{ event in
          if case .load(_,_) = event { return true }
          else if case .error(_) = event { return true}
          else{ return false }
        }
        .map{ event in
          if case .load(let tuple) = event {
            return Result.success(tuple)
          }
          else if case .error(let error) = event {
            return Result.failed(error: error)
          }
          else {
            return Result.failed(error: CastrError.undefined)
          }
      }
    }
  }
  
  func loadMoreMessages(contextId: String, fromMessageId: String) -> Observable<[MessageDto]> {
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .flatMap({ (uid) -> Observable<[MessageDto]> in
        return SocketApi
          .getInstance()
          .getChatroom(chatroomId: contextId)
          .take(1)
          .flatMap({ (chatroomApi) -> Observable<[MessageDto]> in
            return chatroomApi.requestMessagePage(
              fromMessageId: fromMessageId,
              uId: uid)
          })
    })
  }
  
  func receiveNewMessage(contextId: String) -> Observable<MessageDto?> {
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .flatMap{ uid in
      return DataChatroomMessages
        .getChatroomEvents(chatroomId: contextId, uid: uid)
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
  
  func deletedMessage(chatroomId: String) -> Observable<(messageId: String, userId: String, deletedAt: Int)?> {
    return SocketApi
      .getInstance()
      .getChatroom(chatroomId: chatroomId)
      .flatMap{ chatroomApi in
        return chatroomApi
          .toObservable()
          .filter{ event in
            if case .messageDeleted(_, _, _) = event{ return true }
            else {return false}
          }
          .map{ event in
            if case .messageDeleted(let messageId, let userId, let deletedAt) = event {
              return (messageId: messageId, userId: userId, deletedAt: deletedAt)
            }
            else { return nil }
        }
      }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // Messages Methods
  
  func sendMessage(contextId: String, text: String, quotesIds: [String]?) -> Observable<Result<(message: UserMessageDto, localId: String)>> {
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .flatMap({ (uid) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
        return UserService
          .instance
          .toObservable()
          .take(1)
          .flatMap({ (profile) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
            
            // Message Creation
            
            let localMsgId = DataChatroomMessages.genMessageId(chatroomId: contextId)
            let createdMessage = UserMessageDto(type: .text(text: text),
                                                profile: profile,
                                                id: localMsgId,
                                                status: .sending,
                                                isOwn: true)
            
            print("Interactor - New Message created - localId: ", localMsgId)
            
            let createdObs = Observable.just((message: createdMessage, localId: localMsgId))
            
            // Message Informations Update
            
            let sentObs = DataChatroomMessages
              .sendMessage(chatroomId: contextId, message: text, uid: uid)
              .flatMap({ (message) -> Observable<(message: UserMessageDto, localId: String)> in
                print("Interactor - Message Sent Response - localId:", localMsgId)
                var message = message
                message.isOwn = true
                message.status = .sent
                return Observable.just((message: message, localId: localMsgId))
              })
            
            return Observable.merge([createdObs, sentObs])
              .flatMap({ (messageTuple) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
                print("Interactor - Observable message")
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
      .take(1)
      .flatMap({ (uid) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
        return UserService
          .instance
          .toObservable()
          .take(1)
          .flatMap({ (profile) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
            
            let image = UIImage(data: imageData)
            let createdId = DataChatroomMessages.genMessageId(chatroomId: contextId)
            var createdMessage = UserMessageDto(type: .media(mediaWith: .image(image!),
                                                format: .jpeg,
                                                text: text),
                                                profile: profile,
                                                id: createdId,
                                                status: .sending,
                                                isOwn: true)
            
            let createObs = Observable.just((message: createdMessage, localId: createdId))
            
            let uploadObs = FirebaseDatabase.uploadImageToDatabase(context:.uploadMessageRoom(chatroomId: contextId), imageData: imageData)
              .flatMap({ (uploadStatus) -> Observable<(message: UserMessageDto, localId: String)> in
                switch uploadStatus {
                case .uploading(let progression):
                  createdMessage.isOwn = true
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
                      createdMessage.status = .sent
                      return Observable.just((message: createdMessage, localId: createdId))
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
  
  func deleteMessage(chatroomId: String, messageId: String) -> Observable<Result<Void>> {
    print(chatroomId, messageId)
      return DataChatroomMessages.deleteMessage(
          chatroomId: chatroomId,
          messageId: messageId)
      .flatMap{ _ in
        return Observable.just(Result.success())
      }
      .catchError{ error in
        switch error as! SocketError {
        case .cantConnect:
          return Observable.just(Result.failed(error: CastrError.unauthorized))
        default:
          return Observable.just(Result.failed(error: CastrError.undefined))
        }
      }
  }
    
  // -----------------------------------------------------------------------------------------------

  func messageLoved(contextId: String) -> Observable<[String : Any]?> {
    return FirebaseAuth.getAuthUser().flatMap{ uid in
      return DataChatroomMessages
        .getChatroomEvents(chatroomId: contextId, uid: uid)
        .filter{ event in
          if case .messageLoved(messageId: _, loveAmount: _, loveCount: _) = event { return true }
          else{ return false }
        }
        .map{ event in
          if case .messageLoved(let messageId, let loveAmount, _) = event {
            return ["messageId" : messageId,
                    "loveAmount" : loveAmount]
          }
          else { return nil }
      }
    }
  }
  
  // Favorite Chatroom
  
  func addChatroomAsFavorite(chatroomId: String) -> Observable<Void> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataChatrooms.addFavorite(chatroomId: chatroomId, token: token)
    }
  }
  
  func deletedChatroomAsFavorite(chatroomId: String) -> Observable<Void> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataChatrooms.addFavorite(chatroomId: chatroomId, token: token)
    }
  }
  
  func sendLove(chatroom: String, messageId: String, loveAmount: Int) -> Observable<String> {
    return FirebaseAuth
      .getAuthUser()
      .flatMap{ uid in
        return DataChatroomMessages
          .sendLove(chatroomId: chatroom,
                    messageId: messageId,
                    loveAmount: loveAmount, uid: uid)
    }
  }
  
  func leave(contextId: String) {
    DataChatroomMessages.leave(chatroomId: contextId)
  }
  
  func getUid() -> Observable<String> {
    return FirebaseAuth.getAuthUser().map{ uid in
      return uid
    }
  }
  
  
  //MARK: - Magic Words Methods
  
  func getJokeById(jokeId: Int) -> Observable<String> {
    return FirebaseAuth.getToken().flatMap{ token in
      return DataChatroomMessages.getJokeById(id: jokeId, token: token)
    }
  }
  
  func getQuoteById(quoteId: Int) -> Observable<String> {
    return FirebaseAuth.getToken().flatMap{ token in
      return DataChatroomMessages.getQuoteById(id: quoteId, token: token)
    }
  }
  
  //MARK: - Admin Methods
  
  func isValidName(name: String) -> Observable<Bool> {
    return Observable.create{ emitter in
      if name.count != 0 && name.count < 40 {
        emitter.onNext(true)
      }
      else {
        emitter.onNext(false)
      }
      return Disposables.create()
    }
  }
  
  func isValidDescription(description: String) -> Observable<Bool> {
    return Observable.create{ emitter in
      if description.count < 250 {
        emitter.onNext(true)
      }
      else {
        emitter.onNext(false)
      }
      return Disposables.create()
    }
  }
  
  func updateChatroom(chatroomId: String, name: String?, description: String?) -> Observable<Void> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataChatrooms
          .updateChatroomFields(token: token, chatroomId: chatroomId,
                                name: name,
                                description: description)
    }
  }
  
  func changeChatroomColor(chatroomId: String, color: Int) -> Observable<Result<Void>> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataChatrooms
          .updateChatroomColor(token: token, chatroomId: chatroomId, color: color)
      }
      .flatMap{ _ in
        return Observable.just(Result.success())
      }
      .catchError{ error in
        return Observable.just(Result.failed(error: CastrError.undefined))
    }
    
  }
  
  func getChatroomInfosDetails(chatroomId: String) -> Single<Void> {
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
        return DataChatrooms.getChatroomById(
          id: chatroomId,
          token: token)
      }
  }
  
  func closeChatroom(){}
  
  func getAdmins(chatroomId: String)-> Single<[UserDTO]> {
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
        return DataChatrooms.getAdmins(chatroomId: chatroomId, token: token)
      }
  }
  
//  func getModos(chatroomId: String){
//    return FirebaseAuth
//      .getToken()
//      .take(1)
//      .asSingle()
//      .flatMap{ token in
//        return DataChatrooms.getModos(chatroomId: chatroomId, token: token)
//    }
//  }
  
  func getMembersList(chatroomId: String, from: String?) -> Observable<Void> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataChatrooms.getMembersList(token: token, chatroomId: chatroomId, from: from)
    }
  }
  
  func getMemberDetails(chatroomid: String, memberId: String) -> Observable<Result<MemberDetailDto>> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataChatrooms
          .getMemberDetails(token: token, chatroomId: chatroomid, memberId: memberId)
          .flatMap{ memberDetails in
            return Observable.just(Result.success(memberDetails))
          }
      }
      .catchError{ error in
        return Observable.just(Result.failed(error: CastrError.undefined))
      }
  }
  
  func warnMember(chatroomId: String, memberId: String, reason: String?) -> Observable<Result<Void>> {
    return FirebaseAuth
      .getToken()
      .flatMap{ token in
        return DataChatrooms
          .warnMember(token: token,
                      chatroomId: chatroomId,
                      memberId: memberId,
                      reason: reason)
          .flatMap{ _ in
            return Observable.just(Result.success())
          }
      }
      .catchError{ error in
        return Observable.just(Result.failed(error: CastrError.undefined))
    }
  }
  
  func reportMessage(chatroomId: String, messageId: String, reason: String?) -> Single<Result<Void>> {
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
        return DataChatroomMessages
          .reportMessage(
            token: token,
            chatroomId: chatroomId,
            messageId: messageId,
            reason: reason)
      }
      .map{ _ in
        return Result.success()
      }
      .catchError{ error in
        return Single.just(Result.failed(error: CastrError.cantReport))
      }
  }
  
  func banMember(chatroomId: String, memberId: String, reason: String?) -> Observable<Result<Void>> {
    return FirebaseAuth
      .getToken()
      .flatMap{ (token) in
        return DataChatrooms
          .banMember(token: token,
                      chatroomId: chatroomId,
                      memberId: memberId,
                      reason: reason)
          .flatMap{ _ in
            return Observable.just(Result.success())
        }
      }
      .catchError{ error in
        return Observable.just(Result.failed(error: CastrError.undefined))
    }
  }
  
}




