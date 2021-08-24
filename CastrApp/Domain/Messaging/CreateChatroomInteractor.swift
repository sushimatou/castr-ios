//
//  CreateChatroomInteractor.swift
//  CastrApp
//
//  Created by Antoine on 02/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class CreateChatroomInteractor {
    
    func createChatroom(name: String) -> Observable<Result<String>> {
        return FirebaseAuth.getToken()
            .flatMap{ token in
            return FirebaseAuth
                .getAuthUser()
                .flatMap{ uid in
                    return DataChatrooms
                        .createChatroom(token: token, uid: uid, name: name)
                        .flatMap{ chatroomId in
                            return Observable.just(Result.success(chatroomId))
                        }
                        .catchError({ (error) -> Observable<Result<String>> in
                            return Observable.just(Result.failed(error: error as! CastrError))
                        })
                }
        }
    }
    
    func isConnected() -> Observable<Bool> {
        return FirebaseAuth.userIsAnonymous().map{ isAnonymous in
            return !isAnonymous
        }
    }

    func isNameValid(name: String) -> Observable<Bool> {
        return Observable.create{ emitter in
            print(1 ... 40 ~= name.count)
            emitter.onNext(1 ... 40 ~= name.count)
            return Disposables.create()
        }
    }
}
