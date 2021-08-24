//
//  SignUpUsernameViewController.swift
//  CastrApp
//
//  Created by Antoine on 05/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import BEMCheckBox

class SignUpUsernameViewController: UIViewController {
  
  // MARK : - IB Outlets
  
  @IBOutlet weak var createAccountButton: RoundedButton!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var termsCheckBox: BEMCheckBox!
    
  // MARK : - Properties
  var email: String?
  var password: String?
  
  // MARK : - Life Cycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SignUpUsernamePresenter.instance.bind(view: self)
    createAccountButton.isEnabled = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    SignUpUsernamePresenter.instance.unbind(view: self)
  }
  
  // MARK : - Intents & Actions
  
  func usernameEditIntent() -> Observable<String> {
    return usernameTextField
      .rx
      .text
      .orEmpty
      .skip(1)
      .asObservable()
  }
  
  func createAccountIntent() -> Observable<(email: String, password: String, username: String)> {
    return createAccountButton
      .rx
      .tap
      .map{ _ in
        return (email: self.email!,
                password: self.password!,
                username: self.usernameTextField.text!)
      }
  }
    
  @IBAction func seeLegalsAction(_ sender: Any) {
    UIApplication.shared.openURL(URL(string: "http://castr.com/legal")!)
  }
    
  
  // MARK : - Render Methods
  
  func render(state: SignUpUsernameViewState) {
    
    if state.isConnected {
      returnToProfile()
    }
    
    if state.error != nil {
      let alertView = AlertView.loadFromXib()
      alertView?.create(
        title: "Erreur",
        text: "Une erreur est survenue lors de la création de votre compte",
        withCancelButton: false)
    }
    
    usernameTextField.callbackWithState(state: state.username!)
    
    // Because Swift is not so swift sometimes
    
    if case FieldState.valid = state.username! {
      createAccountButton.isEnabled = true
    } else {
      createAccountButton.isEnabled = false
    }
    
  }
  
  func error(error: Error) {
    let alertView = AlertView.loadFromXib()
    alertView!.create(title: "Erreur", text: error.localizedDescription, withCancelButton: false)
    alertView!.show(viewController: self)
  }
  
  func returnToProfile() {
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  func signUpError() {
    self.navigationController?.popToRootViewController(animated: true)
  }
  
}

extension SignUpUsernameViewController : BEMCheckBoxDelegate {
    
}
