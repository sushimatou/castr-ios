//
//  PictureInteractor.swift
//  CastrApp
//
//  Created by Antoine on 25/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class PictureInteractor {
  
  func changePicture(context: PictureContext, imageData: Data) -> Observable<Result<(progress: Progress?, isSent: Bool)>> {
    return FirebaseAuth.getAuthUser().flatMap{ uid in
      return FirebaseAuth.getToken().flatMap({ (token) -> Observable<Result<(progress: Progress?, isSent: Bool)>> in
        
        switch context {
          
        case .userPic(let user, _):
          
          return FirebaseDatabase
            .uploadImageToDatabase(context: UploadType.uploadUserPic(user: user), imageData: imageData)
            .flatMap({ (status) -> Observable<Result<(progress: Progress?, isSent: Bool)>> in
              
              switch status {
              case .uploading(let progress):
                return Observable.just(Result.success(progress: progress, isSent: false))
                
              case .uploaded(let url):
                return DataProfile
                    .userPictureUpdate(uid: uid,
                    token: token,
                    url: url.absoluteString,
                    imageData: imageData)
                    .flatMap{ _ in
                      return Observable.just(Result.success(progress: nil, isSent: true))
                }
              }
          })
                
        case .chatroomPic(let chatroom, _):
          
          return FirebaseDatabase
            .uploadImageToDatabase(context: UploadType.uploadChatroomPic(chatroom: chatroom), imageData: imageData)
            .flatMap({ (status) -> Observable<Result<(progress: Progress?, isSent: Bool)>> in
              switch status {
              case .uploading(let progress):
                return Observable.just(Result.success(progress: progress, isSent: false))
                      
              case .uploaded(let url):
                return DataChatrooms
                  .updateChatroomPicture(uid: uid,
                                         token: token,
                                         url: url.absoluteString,
                                         imageData: imageData,
                                         chatroomId: chatroom.id)
                  .flatMap{ _ in
                    return Observable.just(Result.success(progress: nil, isSent: true))
                  }
              }
          })
        }
        
      })
    }
    .catchError{ error in
        return Observable.just(Result.failed(error: CastrError.undefined))
    }
  }
  
//  func deletePicture(context: PictureContext) -> Observable<Result<Void>> {
//    switch context {
//      
//    case .userPic(let user):
//      return DataChatrooms.dele
//    case .chatroomPic(let chatroom):
//      
//    }
//  }
  
}
