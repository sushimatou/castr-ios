//
//  CreateChatroomViewController.swift
//  CastrApp
//
//  Created by Antoine on 25/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxKeyboard

class CreateChatroomViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var chatroomNameTextField: UITextField!
  @IBOutlet weak var createChatroomButton: RoundedButton!
  @IBOutlet weak var waitingView: UIView!
  @IBOutlet weak var similarsTableView: UITableView!
  @IBOutlet weak var createButtonBottomConstraint: NSLayoutConstraint!
    
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  var similars = [SearchResultsDto]()
  
  // MARK: - Life Cycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.obsKeyboard()
    self.chatroomNameTextField.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    CreateChatroomPresenter.instance.bind(view: self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    CreateChatroomPresenter.instance.unbind(view: self)
  }
  
  func editNameIntent() -> Observable<String> {
    return self.chatroomNameTextField
      .rx
      .text
      .orEmpty
      .skip(2)
      .debounce(0.5, scheduler: MainScheduler.instance)
  }
  
  func createChatroomIntent() -> Observable<String?> {
    return self.createChatroomButton
      .rx
      .tap
      .map{
        return self.chatroomNameTextField.text
    }
  }
  
  // Reactive Keyboard
  
  func obsKeyboard() {
    
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { keyboardVisibleHeight in
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0) {
          self.createButtonBottomConstraint.constant = 20 + keyboardVisibleHeight
          self.view.layoutIfNeeded()
        }
      })
      .disposed(by: disposeBag)
    
    RxKeyboard.instance.willShowVisibleHeight
      .drive(onNext: { keyboardVisibleHeight in
        self.createButtonBottomConstraint.constant = 20 + keyboardVisibleHeight
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Render Methods
  
  func render(state: CreateChatroomState) {
    
    self.waitingView.isHidden = !state.isLoading
    
    if state.isEnabled {
      
      self.chatroomNameTextField.callbackWithState(state: state.chatroomNameState!)
      self.similars = state.chatroomResults
      similarsTableView.reloadData()
    
      if case FieldState.valid = state.chatroomNameState! {
        self.createChatroomButton.isEnabled = true
      }
      else {
        self.createChatroomButton.isEnabled = false
      }
      
      if state.createdId != nil {
        goToCreatedChatroom(createdId: state.createdId!)
      }
      
    }
    else {
      accessDenied()
    }
  }
  
  func error(error: Error) {
    let alertView = AlertView.loadFromXib()
    alertView!.create(title: "Erreur",
                      text: error.localizedDescription,
                      withCancelButton: false)
    alertView!.show(viewController: self)
  }
  
  // MARK: - Navigation
  
  func goToCreatedChatroom(createdId: String) {
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomViewController") as! MessagingViewController
    vc.context = .chatroom
    vc.contextId = createdId
    let nav = self.navigationController
    self.navigationController?.popToRootViewController(animated: false)
    nav!.pushViewController(vc, animated: true)
  }
  
  func accessDenied() {
    let alertView = AlertView.loadFromXib()
    alertView!.create(title: "Inscription Requise",
                      text: "Vous devez être inscrit pour pouvoir créer vos propres chatrooms.",
                      okCompletionHandler: {
                        self.navigationController?.popToRootViewController(animated: true)
                      },
                      withCancelButton: false)
    view.endEditing(true)
    self.chatroomNameTextField.resignFirstResponder()
    alertView!.show(viewController: self)
  }
}

// MARK: - TableView Datasource & Delegate Methods

extension CreateChatroomViewController : UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return similars.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteCellId") as! SearchResultTableViewCell
    cell.result = similars[indexPath.row]
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Chatrooms Similaires"
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chatroomVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomViewController") as! MessagingViewController
    chatroomVc.context = .chatroom
    chatroomVc.contextId = similars[indexPath.row].id
    self.navigationController?.pushViewController(chatroomVc, animated: true)
  }
  
}
