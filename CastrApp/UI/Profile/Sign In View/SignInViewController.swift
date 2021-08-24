//
//  SignInViewController.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift

class SignInViewController: UIViewController {
  
  // ---------------------------------------------------------------------------------------------
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var mailTextField: CustomTextField!
  @IBOutlet weak var pwdTextField: CustomTextField!
  @IBOutlet weak var signInButton: RoundedButton!
  
  // ---------------------------------------------------------------------------------------------
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.mailTextField.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    SignInPresenter.instance.bind(view: self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    SignInPresenter.instance.unbind()
  }
  
  // ---------------------------------------------------------------------------------------------
  
  // MARK: Intents
  
  func mailEditIntent() -> Observable<String> {
    return mailTextField
      .rx
      .text
      .orEmpty
      .map{ text in
        return text
    }
  }
  
  func pwdEditIntent() -> Observable<String> {
    return pwdTextField
      .rx
      .text
      .orEmpty
      .map{ text in
        return text
    }
  }
  
  func signInIntent() -> Observable<(mail: String, pwd: String)> {
    return signInButton
      .rx
      .tap
      .map{ _ in
        return (self.mailTextField.text!, self.pwdTextField.text!)
    }
  }
  
  // ---------------------------------------------------------------------------------------------
  
  // MARK: Render
  
  func render(state: SignInViewState) {
    
    switch state {
    case .empty:
      break //NOOP
      
    case .loading:
      break
      
    case .editing(let mailFieldState, let pwdFieldState):
      self.mailTextField.callbackWithState(state: mailFieldState)
      self.pwdTextField.callbackWithState(state: pwdFieldState)
      
      if case FieldState.valid = mailFieldState,
        case FieldState.valid = pwdFieldState {
        self.signInButton.isEnabled = true
      }
      else {
        self.signInButton.isEnabled = false
      }
      
    case .connected:
      self.returnToConnectedProfile()
      
    case .error(let error):
      let alertView = AlertView.loadFromXib()
      alertView?.create(title: "Erreur", text: error.rawValue, withCancelButton: false)
      alertView?.show(viewController: self)
      
    }
  }
  
  private func returnToConnectedProfile() {
    self.navigationController?.popToRootViewController(animated: true)
  }
  
}
