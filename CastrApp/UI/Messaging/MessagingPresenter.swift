//
//  ChatroomPresenter.swift
//  CastrApp
//
//  Created by Antoine on 18/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class MessagingPresenter {
  
  // MARK: - Properties
  
  // Instances Gestion
  
  static var instances: [String:MessagingPresenter] = [:]
  static func getPresenter(contextId: String) -> MessagingPresenter {
    if !instances.keys.contains(contextId) {
      instances[contextId] = MessagingPresenter()
    }
    return instances[contextId]!
  }
  
  // TODO: May use a queue with limited size if memory becomes a problem
  
  // Properties

  let relay = PublishSubject<MessagingAction>()
  var view = MessagingViewController()
  let chatInteractor = ChatInteractor()
  let chatroomInteractor = ChatroomInteractor()
  var interactor: MessagingInteractorProtocol?
  var disposable: Disposable? = nil
  var currentState = MessagingViewState()
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Bind View
  
  func bind(view : MessagingViewController, context: MessagingContext) {
    
    var mergedObservables = [Observable<MessagingAction>]()
    
    self.view = view
    
    switch context {
      
    case .chat:
      self.interactor = chatInteractor
      mergedObservables = [
        obsLoad(interactor: interactor!),
        obsLoadMoreMessages(interactor: interactor!),
        obsReceivedMessage(interactor: interactor!),
        obsSendMessageIntent(interactor: interactor!),
        obsAddPhotoIntent(),
        obsClearPhotoIntent(),
        relay]
      
    case .chatroom:
      self.interactor = chatroomInteractor
      mergedObservables = [
        obsProfile(),
        obsBlockUserIntent(interactor: interactor! as! ChatroomInteractor),
        obsUnblockUserIntent(interactor: interactor! as! ChatroomInteractor),
        obsReportIntent(interactor: interactor! as! ChatroomInteractor),
        obsCastrBotMessages(interactor: interactor! as! ChatroomInteractor),
        obsAddOrRemoveFavorite(interactor: interactor! as! ChatroomInteractor),
        obsLoad(interactor: interactor! as! ChatroomInteractor),
        obsLoadMoreMessages(interactor: interactor!),
        obsReceivedMessage(interactor:  interactor!),
        obsDeletedMessage(interactor: interactor! as! ChatroomInteractor),
        obsSendMessageIntent(interactor:  interactor!),
        obsUpdateLoves(interactor:  interactor! as! ChatroomInteractor),
        obsSendLovesIntent(interactor:  interactor! as! ChatroomInteractor),
        obsAddPhotoIntent(),
        obsClearPhotoIntent(),
        relay]
    }

    disposable?.dispose()
    disposable = Observable.merge(mergedObservables)
      .scan(currentState, accumulator: reduceViewState)
      .subscribe(onNext: { (result) in
        view.render(state: result)
    },
                 onError: nil,
                 onCompleted: nil,
                 onDisposed: { _ in
      })
  }
  
  func unbind(){
    interactor!.leave(contextId: view.contextId)
    disposable?.dispose()
    disposable = nil
  }

  // -----------------------------------------------------------------------------------------------
  
  // Messages Observables
  
  // Loading Messages
  
  func obsLoad(interactor: MessagingInteractorProtocol) -> Observable<MessagingAction> {
    return interactor
      .load(contextId: view.contextId)
      .map{ result in
        switch result {
        case .success(let tuple):
          return .load(messages: tuple.messages, infos: tuple.infos )
        case .failed(let error):
          return .showError(error)
        }
    }
  }
  
  func obsLoadMoreMessages(interactor: MessagingInteractorProtocol) -> Observable<MessagingAction> {
    return view
      .loadMoreSubject
      .do(onNext: { (_) in
        self.relay.onNext(.startLoadMore)
      })
      .flatMap{ messageId in
        return interactor
          .loadMoreMessages(contextId: self.view.contextId,
                            fromMessageId: messageId)
      }
      .map{ messages in
        return MessagingAction.loadMoreMsg(messages: messages)
      }
  }
  
  func obsCastrBotMessages(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return interactor
      .loadCastrBotMessages()
      .map{ message in
        return .receiveMsg(message: message)
      }
  } 
  
  // Receive New Message
  
  func obsReceivedMessage(interactor: MessagingInteractorProtocol) -> Observable<MessagingAction> {
    return interactor
      .receiveNewMessage(contextId: view.contextId)
      .map{ message in
        return .receiveMsg(message: message!)
    }
  }
  
  // Send New Message
  
  func obsSendMessageIntent(interactor: MessagingInteractorProtocol) -> Observable<MessagingAction> {
    return view
      .sendMessageIntent()
      .flatMap({ (message) -> Observable<Result<(message: UserMessageDto, localId: String)>> in
        
        // media message
        if let imageData = message.image {
          return interactor
            .sendMediaMessage(contextId: self.view.contextId,
                              imageData: imageData,
                              text: message.text,
                              quotesIds: [])
        }
        // text message
        else {
          return interactor
            .sendMessage(contextId: self.view.contextId,
                         text: message.text!,
                         quotesIds: nil)
        }
      })
      .map{ result in
        switch result {
        case .success(let messageTuple):
          return MessagingAction.sendMsg(message: messageTuple.message,
                                         localId: messageTuple.localId)
        case .failed(_):
          return MessagingAction.undefined
        }
      }
  }
  
  func obsDeletedMessage(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return interactor
      .deletedMessage(chatroomId: self.view.contextId)
      .map{ deletedMessageInfos in
        return .deletedMessage(
          messageId: deletedMessageInfos!.messageId,
          userId: deletedMessageInfos!.userId,
          deletedAt: deletedMessageInfos!.deletedAt)
      }
  }
  
  func obsTextEditIntent() -> Observable<MessagingAction> {
    return view
      .textEditIntent()
      .map {text in
       return MessagingAction.undefined
      }
  }
  
  
  // -----------------------------------------------------------------------------------------------
  
  
  func obsAddOrRemoveFavorite(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return view
      .addOrRemoveFavoriteIntent()
      .do(onNext: { (isSelected) in
        self.relay.onNext(MessagingAction.setFavoriteState(favorite: !isSelected))
      })
      .debounce(0.5, scheduler: MainScheduler.instance)
      .flatMap({ (isSelected) -> Observable<Void> in
        if isSelected{
          return interactor.deletedChatroomAsFavorite(chatroomId: self.view.contextId)
        }
        else {
          return interactor.addChatroomAsFavorite(chatroomId: self.view.contextId)
        }
      })
      .map{ _ in
       return MessagingAction.undefined
    }
  }
  
  
  // -----------------------------------------------------------------------------------------------
  
  // Media Observables
  
  private func obsAddPhotoIntent() -> Observable<MessagingAction> {
    return self
      .view
      .addPhotoSubject
      .map{ image in
        return MessagingAction.setMediaAttachment(media: image)
      }
  }
  
  private func obsClearPhotoIntent() -> Observable<MessagingAction> {
    return self.view
      .clearPhotoIntent()
      .map{ _ in
        return .setMediaAttachment(media: nil)
    }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // Messages Actions Observables
  
  private func obsReportIntent(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return self
      .view
      .reportSubject
      .flatMap{ args in
        return interactor
          .reportMessage(
            chatroomId: self.view.contextId,
            messageId: args.messageId,
            reason: args.reason)
      }
      .map{ result in
        switch result{
        case .success():
          return .setReported(reported: true)
        case .failed(_):
          return .setReported(reported: false)
        }
      }
  }
  
  private func obsBlockUserIntent(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return self
      .view
      .blockSubject
      .flatMap{ blacklistedId in
        return UserService.instance.blockUser(blackListedId: blacklistedId)
      }
      .map{ result in
        switch result{
        case .success(_):
          return MessagingAction.setBlocked(blocked: true)
        case .failed(_):
          return MessagingAction.setBlocked(blocked: false)
        }
      }
  }
  
  private func obsUnblockUserIntent(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return self
      .view
      .blockSubject
      .flatMap{ blacklistedId in
        return UserService.instance.unblockUser(blackListedId: blacklistedId)
      }
      .map{ result in
        switch result{
        case .success(_):
          return MessagingAction.setUnblocked(unblocked: true)
        case .failed(_):
          return MessagingAction.setUnblocked(unblocked: false)
        }
    }
  }
  
  private func obsProfile() -> Observable<MessagingAction> {
    return UserService
      .instance
      .toObservable()
      .map{profile in
        return MessagingAction.loadProfile(profile)
      }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // Loves Observables
  
  func obsUpdateLoves(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return interactor
      .messageLoved(contextId: view.contextId)
      .map{ infos in
        let messageId = infos!["messageId"] as! String
        let loveAmount = infos!["loveAmount"] as! Int
        return MessagingAction.updateLoves(messageId: messageId, loveAmount: loveAmount)
    }
  }
  
  func obsSendLovesIntent(interactor: ChatroomInteractor) -> Observable<MessagingAction> {
    return view.addLoveSubject.asObservable()
      .flatMap({ (infos) -> Observable<String> in
        let messageId = infos["message_id"] as! String
        let loveAmount = infos["loveAmount"] as! Int
        return interactor.sendLove(chatroom: self.view.contextId, messageId: messageId, loveAmount: loveAmount)
      })
      .map{_ in
        return MessagingAction.undefined
    }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Reduce State
  
  func reduceViewState(previousState: MessagingViewState, changes: MessagingAction) -> MessagingViewState {
    
    var newState = previousState
    
    switch changes {
      
    case .sendMsg(let message, let localId):
      
      if let localMsgIndex = newState.messages.index(where: { (messageFromList) -> Bool in
        return messageFromList.id == localId
      }) {
        newState.messages[localMsgIndex] = MessageDto(id: message.msgId, type: .userMessage(message: message))
        newState.shouldScrollToBottom = false
      }
      else {
        newState.messages.append(MessageDto(id: message.msgId, type: .userMessage(message: message)))
        newState.shouldScrollToBottom = true
      }
      
      newState.datesSections = MessagingSorting.createDateSectionsListByMessages(messages: newState.messages)
      newState.groupedMessages = MessagingSorting.groupMessagesByDateSections(datesSections: newState.datesSections, messages: newState.messages)
      newState.media = nil
      newState.isNewPage = false
      newState.isLoadingMore = false
      newState.blocked = nil
      newState.unblocked = nil
      return newState
      
    // ---------------------------------------------------------------------------------------------
      
    case .load(let messages, let infos):
      
      newState.isAtTop = messages.count < 25
      newState.shouldScrollToBottom = messages.count > 0
      switch infos {
      case .chat(_):
        break // NOOP
      case .chatroom(let chatroomInfos):
        if chatroomInfos.role == Role.admin && messages.count == 0 {
          self.chatroomInteractor.generateCastrBotMessage()
        }
      }
      
      newState.messages = messages
      newState.datesSections = MessagingSorting.createDateSectionsListByMessages(messages: newState.messages)
      newState.groupedMessages = MessagingSorting.groupMessagesByDateSections(datesSections: newState.datesSections, messages: newState.messages)
      newState.infos = infos
      newState.canLoadMore = false
      newState.isLoading = false
      newState.isLoadingMore = false
      newState.isNewPage = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
      
    // ---------------------------------------------------------------------------------------------

    case .loadMoreMsg(let messages):
      var newMessages = messages
      newMessages.remove(at: newMessages.count - 1)
      newState.messages.insert(contentsOf: newMessages, at: 0)
      newState.datesSections = MessagingSorting.createDateSectionsListByMessages(messages: newState.messages)
      newState.groupedMessages = MessagingSorting.groupMessagesByDateSections(datesSections: newState.datesSections, messages: newState.messages)
      
      newState.isLoadingMore = false
      newState.isAtTop = messages.count < 20
      newState.isSendingMsg = false
      newState.isNewPage = true
      newState.shouldScrollToBottom = false
      
    case .startLoadMore:
      newState.isLoadingMore = true
      newState.shouldScrollToBottom = false
      newState.isNewPage = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
     
    // ---------------------------------------------------------------------------------------------
      
    case .deletedMessage(let messageId, _, _):
      if let messageDeletedIndex = newState.messages.index(where: { (messageFromList) -> Bool in
        return messageFromList.id == messageId
      }){
        if case MessageType.userMessage(message: let message) = newState.messages[messageDeletedIndex].type {
          var deletedMessage = message
          deletedMessage.type = .deleted
          newState.messages[messageDeletedIndex] = MessageDto(id: deletedMessage.msgId, type: .userMessage(message: deletedMessage), createdAt: Double(deletedMessage.createdAt))
        }
        newState.isSendingMsg = true
      }
      newState.datesSections = MessagingSorting.createDateSectionsListByMessages(messages: newState.messages)
      newState.groupedMessages = MessagingSorting.groupMessagesByDateSections(datesSections: newState.datesSections, messages: newState.messages)
      
      newState.isLoadingMore = false
      newState.isSendingMsg = false
      newState.isNewPage = false
      newState.shouldScrollToBottom = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
    
    // ---------------------------------------------------------------------------------------------
     
    case .receiveMsg(let message):
      
      if let localMsgIndex = newState.messages.index(where: { (messageFromList) -> Bool in
        return messageFromList.id == message.id
      }){
        newState.messages[localMsgIndex] = message
        newState.isSendingMsg = true
        newState.shouldScrollToBottom = false
      } else {
        newState.messages.append(message)
        newState.shouldScrollToBottom = true
      }
      newState.datesSections = MessagingSorting.createDateSectionsListByMessages(messages: newState.messages)
      newState.groupedMessages = MessagingSorting.groupMessagesByDateSections(datesSections: newState.datesSections, messages: newState.messages)
      newState.isNewPage = false
      newState.isLoadingMore = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
      
      
    // ---------------------------------------------------------------------------------------------
      
    case .updateLoves(let messageId, let loveAmount):
      let messageIndex = newState.messages.index(where: { (message) -> Bool in
        message.id == messageId
      })
      if case MessageType.userMessage(let userMessage) = newState.messages[messageIndex!].type {
        var userMessage = userMessage
        userMessage.love  += loveAmount
        newState.messages[messageIndex!].type = .userMessage(message: userMessage)
      }
      newState.datesSections = MessagingSorting.createDateSectionsListByMessages(messages: newState.messages)
      newState.groupedMessages = MessagingSorting.groupMessagesByDateSections(datesSections: newState.datesSections, messages: newState.messages)
      newState.shouldScrollToBottom = false
      newState.isNewPage = false
      newState.isLoadingMore = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
      
    case .setFavoriteState(let favorite):
      switch newState.infos! {
      case .chatroom(let chatroom):
        var infos = chatroom
        infos.isFavorite = favorite
        newState.infos = MessagingInfos.chatroom(infos)
        newState.isLoadingMore = false
        newState.reported = nil
        newState.blocked = nil
        newState.unblocked = nil
      default:
        break // NOOP
      }
      newState.shouldScrollToBottom = false
      
    case .setMediaAttachment(let media):
      newState.media = media
      newState.isLoadingMore = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
      
    case .loadProfile(let profile):
      newState.profile = profile
      newState.shouldScrollToBottom = false
      newState.isLoadingMore = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
      
    case .showError(let error):
      newState.error = error
      newState.shouldScrollToBottom = false
      newState.isLoadingMore = false
      newState.reported = nil
      newState.blocked = nil
      newState.unblocked = nil
      
    case .setReported(let reported):
      newState.reported = reported
      
    case.undefined:
      newState.reported = nil
      break
      
    case .setBlocked(let blocked):
      newState.blocked = blocked
      
    case .setUnblocked(let unblocked):
      newState.unblocked = unblocked
    }
    
    currentState = newState;
    return newState
      
  }
}


