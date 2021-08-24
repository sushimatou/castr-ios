//
//  CastrService.swift
//  CastrApp
//
//  Created by Antoine on 19/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class UserService {
  
  // Properties
  
  static let instance = UserService()
  private let profileSubject = PublishSubject<UserDTO>()
  private var disposable: Disposable?
  private var profile: UserDTO?
  
  // Public Functions
  
  public func start() {
    let obs = Observable.merge([self.joinProfileEvents(), self.watchProfileEvents(), self.getBlackList().asObservable()])
    self.disposable?.dispose()
    self.disposable = obs
      .scan(UserDTO(), accumulator: reduceProfile)
      .subscribe(onNext: { (profile) in
        self.profile = profile
        self.profileSubject.onNext(profile)
      })
  }
  
  public func stop() {
    self.profile = nil
    self.disposable?.dispose()
  }
  
  public func resume() {
    self.disposable?.dispose()
  }
  
  public func toObservable() -> Observable<UserDTO> {
    if self.profile != nil {
      return Observable.concat(Observable.of(profile!), self.profileSubject)
    }
    else {
      return self.profileSubject
    }
  }
  
  public func signUp(email: String, password: String, username: String) -> Single<Result<Void>> {
    print("user service - sign up")
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
          return DataProfile
            .signUp(
              email: email,
              password: password,
              username: username,
              token: token)
            .flatMap{ _ in
              return FirebaseAuth.signIn(email: email, password: password)
            }
            .map{ _ in
              return Result.success()
            }
            .catchError{ error in
              print("user service - sign up error")
              return Single.just(Result.failed(error: CastrError.undefined))
            }
      }
  }
  
  public func logOut() -> Observable<Void> {
    return FirebaseAuth.logOut()
  }
  
  public func changeColor(color: Int) -> Single<Result<Void>> {
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .asSingle()
      .flatMap{ uid in
        return FirebaseAuth
          .getToken()
          .take(1)
          .asSingle()
          .flatMap{ token in
            DataProfile.userUpdate(uid: uid, token: token, update: ["color": color])
          }
          .map{ _ in
            return Result.success()
          }
          .catchError{ error in
            return Single.just(Result.failed(error: CastrError.cantChangeUsername))
        }
    }
  }
  
  public func genName() -> Single<Result<(adj: String, noun: String)>> {
    print("user service - name generation")
    return SocketApi
      .getInstance()
      .getUser()
      .take(1)
      .asSingle()
      .flatMap{ userApi in
        return userApi.generateName()
      }
      .map{ args in
        return Result.success(args)
      }
      .catchError({ (error) -> Single<Result<(adj: String, noun: String)>> in
        return Single.just(Result.failed(error: CastrError.cantGenerateName))
      })
  }
  
  public func changeName(name: String) -> Single<Result<Void>> {
    print("user service - change name")
    return FirebaseAuth
      .getAuthUser()
      .take(1)
      .asSingle()
      .flatMap{ uid in
        return FirebaseAuth
          .getToken()
          .take(1)
          .asSingle()
          .flatMap{ token in
            DataProfile.userUpdate(uid: uid, token: token, update: ["name": name])
          }
          .map{ _ in
            return Result.success()
          }
          .catchError({ (error) -> Single<Result<Void>> in
            return Single.just(Result.failed(error: CastrError.cantChangeUsername))
          })
      }
  }
  
  public func blockUser(blackListedId: String) -> Single<Result<Void>> {
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
        return FirebaseAuth
          .getAuthUser()
          .take(1)
          .asSingle()
          .flatMap{ uid in
            return DataProfile
              .blockUser(userId: uid, token: token, blackListedUserId: blackListedId)
          }
          .map{_ in
            return Result.success()
          }
          .catchError{ error in
            return Single.just(Result.failed(error: CastrError.canAddToBlackList))
          }
      }
  }
  
  public func unblockUser(blackListedId: String) -> Single<Result<Void>> {
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
        return FirebaseAuth
          .getAuthUser()
          .take(1)
          .asSingle()
          .flatMap{ uid in
            return DataProfile
              .unblockUser(userId: uid, token: token, blackListedUserId: blackListedId)
          }
          .map{_ in
            return Result.success()
          }
          .catchError{ error in
            return Single.just(Result.failed(error: CastrError.cantRemoveFromBlackList))
          }
    }
  }
  
  public func updateNotificationSettings(setting: String, value: Bool) -> Single<Result<Void>> {
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
        return FirebaseAuth
          .getAuthUser()
          .take(1)
          .asSingle()
          .flatMap{uid in
            DataProfile.notificationSettingUpdate(setting: setting, value: value, token: token, uid: uid)
          }
          .map{ _ in
            return Result.success()
          }
          .catchError{ error in
            return Single.just(Result.failed(error: CastrError.cantChangeSettings))
          }
      }
  }

  // Private Functions
  
  fileprivate func joinProfileEvents() -> Observable<UserEvent> {
    return SocketApi
      .getInstance()
      .getUser()
      .flatMapLatest({ (userApi) -> Observable<UserEvent> in
        return userApi.join()
      })
  }
  
  fileprivate func getBlackList() -> Single<UserEvent> {
    return FirebaseAuth
      .getToken()
      .take(1)
      .asSingle()
      .flatMap{ token in
        return FirebaseAuth
          .getAuthUser()
          .take(1)
          .asSingle()
          .flatMap{ uid in
            return DataProfile
              .getBlacklist(userId: uid, token: token)
          }
          .map{ users in
            return UserEvent.loadBlacklist(blacklist: users)
          }
    }
  }
  
  fileprivate func watchProfileEvents() -> Observable<UserEvent> {
    return SocketApi
      .getInstance()
      .getUser()
      .flatMapLatest({ (userApi) -> Observable<UserEvent> in
        return userApi.observeEvents()
      })
  }

  fileprivate func reduceProfile(profile: UserDTO, changes: UserEvent) -> UserDTO {
    
    var newProfile = profile
    
    switch changes {
      
    case .profileLoaded(let profile):
      print("user service - profile", profile)
      newProfile = profile
      
    case .profileUpdated(let name, let color, let isRegistered, let picture):
      print("user service - profile updated")
      if name != nil {
        newProfile.name = name!
      }
      if color != nil {
        newProfile.color = color!
      }
      if isRegistered != nil {
        newProfile.isRegistered = isRegistered!
      }
      if picture != nil {
        newProfile.picture = picture!
      }
      
    case .statsUpdated(let stats):
      if let loves = stats.loves {
        newProfile.loves = loves
      }
      if let messages = stats.messages {
        newProfile.messages = messages
      }
      
    case .addUserToBlackList(let blacklistedUserId):
      newProfile.blackList.append(blacklistedUserId)
      
    case .removeUserFromBlacklist(let blacklistedUserId):
      let index = newProfile.blackList.index(where: { (id) -> Bool in
        return id == blacklistedUserId
      })
      newProfile.blackList.remove(at: index!)
      
    case .loadBlacklist(let blacklist):
      newProfile.blackList = blacklist
    }
    
    return newProfile
  }
}

