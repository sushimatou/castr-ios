//
//  SignUpViewController.swift
//  CastrApp
//
//  Created by Antoine on 01/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
  
  // MARK: - IB Outlets
  
  @IBOutlet weak var mailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  
  // MARK: - View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SignUpPresenter.instance.bind(view: self)
    nextButton.isEnabled = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    SignUpPresenter.instance.unbind(view: self)
  }
  
  // MARK: - Intents
  
  func mailEditIntent() -> Observable<String> {
    return mailTextField
      .rx
      .text
      .orEmpty
      .skip(1)
      .asObservable()
  }
  
  func pwdEditIntent() -> Observable<String> {
    return passwordTextField
      .rx
      .text
      .orEmpty
      .skip(1)
      .asObservable()
  }
  
  func confirmCredentialsIntent() -> Observable<Void> {
    return nextButton
      .rx
      .tap
      .debounce(0.5, scheduler: MainScheduler.instance)
  }
  
  // MARK: - Render Function
  
  func render(state: SignUpState){
    if case FieldState.valid = state.mail!, case FieldState.valid = state.pwd! {
      nextButton.isEnabled = true
    } else {
      nextButton.isEnabled = false
    }
    self.mailTextField.callbackWithState(state: state.mail!)
    self.passwordTextField.callbackWithState(state: state.pwd!)
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let signUpUserNameViewController = segue.destination as! SignUpUsernameViewController
    let email = mailTextField.text!
    let pwd = passwordTextField.text!
    signUpUserNameViewController.email = email
    signUpUserNameViewController.password = pwd
  }
  
}
