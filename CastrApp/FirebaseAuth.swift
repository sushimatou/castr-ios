//
//  FirebaseApi.swift
//  CastrApp
//
//  Created by Castr on 26/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import RxSwift
import Birdsong

class FirebaseAuth {
  
  // MARK: - Properties
  
  static let ref = Database.database().reference()
  static var userSubject = BehaviorSubject<String>(value: "")
  static var tokenSubject = BehaviorSubject<String>(value:"")
  static var isAnonymousSubject = BehaviorSubject<Bool>(value:true)
  static var isAnonymous: Bool? = nil
  static var listenerAuthHandle: AuthStateDidChangeListenerHandle? = nil
  static var listenerTokenHandle: IDTokenDidChangeListenerHandle? = nil
  static var changeTokenListener: IDTokenDidChangeListenerBlock = { (auth, user) in
    print("token has changed")
  }
  
  static let changeAuthListener: AuthStateDidChangeListenerBlock = { (auth, user) in

    if user?.uid != nil {
      print("UID",user!.uid)
      print("uid not nil")
      Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (token, error) in
        
        if error != nil {
          tokenSubject.onError(error!)
          isAnonymousSubject.onError(error!)
        }
        
        else {
          tokenSubject.onNext(token!)
          isAnonymousSubject.onNext(user!.isAnonymous)
          print("DEBUGSOCKET", "firebase auth - uid: ", user!.uid)
          SocketApi.getInstance().connect(uid: user!.uid, token: token!)
        }
      })
      
      ref.child("users/profiles/\(user!.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
        userSubject.onNext(user!.uid)
        isAnonymousSubject.onNext(user!.isAnonymous)
      })
    }
  }
  
  // MARK: - Auth Methods
  
  // Link Credientials -----------------------------------------------------------------------------
  
  static func signUp(email: String, password: String, username: String) -> Observable<Void> {
    
    return Observable<Void>.create{emitter in
      
      ref.child("users/usernames/").observeSingleEvent(of: .value, with: { (snapshot) in
        let data = snapshot.value as? NSDictionary
        let existingName = data?.allValues.contains { element -> Bool in
          if username == element as! String{ return true }
          else { return false }
        }

        if !existingName! {
          let credential = EmailAuthProvider.credential(withEmail: email, password: password)
          Auth.auth().currentUser?.link(with: credential, completion: { (user, error) in
            if error != nil {
              emitter.onError(error!)
            } else {
              emitter.onNext()
            }
          })
        }
        
      })
      return Disposables.create()
    }
    
  }
  
  // Log In ---------------------------------------------------------------------------------------
  
  static func signIn(email: String, password: String) -> Single<Void> {
    
    return Single.create{ emitter in
        
      let credential = EmailAuthProvider.credential(withEmail: email, password: password)
      Auth.auth().signIn(with: credential, completion: { (user, error) in
        if let error = error {
          emitter(.error(error))
        }
        else {
          emitter(.success())
        }
      })
      return Disposables.create()
    }
    
  }
  
  // Log Out ---------------------------------------------------------------------------------------
  
  static func logOut() -> Observable<Void> {
    return Observable.create { emitter in
      let firebaseAuth = Auth.auth()
      do {
        try firebaseAuth.signOut()
        firebaseAuth.signInAnonymously(completion: { (user, error) in
          emitter.onNext()
          emitter.onCompleted()
        })
      } catch let signOutError as NSError {
        emitter.onError(signOutError)
      }
      return Disposables.create()
    }
  }
  
  // Firebase Auth Start/ Stop ---------------------------------------------------------------------
  
  static func start() {
    
    listenerAuthHandle = Auth.auth().addStateDidChangeListener(changeAuthListener)
    listenerTokenHandle = Auth.auth().addIDTokenDidChangeListener(changeTokenListener)
    
    if (Auth.auth().currentUser?.uid == nil) {
      Auth.auth().signInAnonymously(completion: { (user, error) in
        print("UID",user?.uid)
      })

    }
    else{
      Auth.auth().currentUser?.reload(completion: { (error) in
        print("UID", Auth.auth().currentUser?.uid)
      })
    }
  }
  
  static func stop() {
    if (listenerAuthHandle != nil) {
      Auth.auth().removeStateDidChangeListener(listenerAuthHandle!)
      Auth.auth().removeIDTokenDidChangeListener(listenerTokenHandle!)
    }
  }
  
  // Subjects Updates ------------------------------------------------------------------------------
  
  static func getAuthUser() -> Observable<String> {
    return userSubject
      .asObservable()
      .filter({ (uid) -> Bool in
        return uid != ""
      })
  }
  
  static func userIsAnonymous() -> Observable<Bool> {
    return isAnonymousSubject
      .asObservable()
  }
  
  static func getToken() -> Observable<String> {
    return tokenSubject
      .asObservable()
      .filter({ (token) -> Bool in
        return token != ""
      })
  }
  
}


