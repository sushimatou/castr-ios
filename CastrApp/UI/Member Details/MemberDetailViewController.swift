//
//  MemberDetailViewController.swift
//  CastrApp
//
//  Created by Antoine on 28/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MemberDetailViewController: UIViewController {
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - IBOutlets
    
  @IBOutlet weak var waitingView: UIView!
  @IBOutlet weak var messageCountsLabel: UILabel!
  @IBOutlet weak var lovesCountLabel: UILabel!
  @IBOutlet weak var sendWarningButton: UIButton!
  @IBOutlet weak var changeRoleButton: UIButton!
  @IBOutlet weak var rolePickerView: UIPickerView!
  @IBOutlet weak var banButton: UIButton!
  @IBOutlet weak var discussButton: UIButton!
    @IBOutlet weak var memberRoleLabel: UILabel!
  
  // -----------------------------------------------------------------------------------------------
    
  // MARK: - Properties
  
  let changeRoleSubject = PublishSubject<Role>()
  let warnSubject = PublishSubject<String?>()
  let banSubject = PublishSubject<String?>()

  lazy var toolbar: UIToolbar = {
    let toolbar = UIToolbar()
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    toolbar.setItems([flexibleSpace,doneButton], animated: false)
    toolbar.sizeToFit()
    toolbar.tintColor = UIColor.white
    toolbar.barTintColor = UIColor.darkGray
    return toolbar
  }()
  
  var username: String!
  var userId: String!
  var chatroomId: String!
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Life Cycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.waitingView.isHidden = false
    self.navigationController?.title = username
  }
  
  override func viewWillAppear(_ animated: Bool) {
    MemberDetailPresenter.instance.bind(view: self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    MemberDetailPresenter.instance.unbind()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Render
  
  func render(state: MemberDetailViewState) {
    
    self.waitingView.isHidden = !state.isLoading
    
    if let memberDetails = state.memberDetails {
      
      self.lovesCountLabel.text = String(memberDetails.love)
      self.messageCountsLabel.text = String(memberDetails.messages)
      
      switch memberDetails.role {
      case .admin:
        self.memberRoleLabel.text = "administrateur".uppercased()
        
      case .moderator:
        self.memberRoleLabel.text = "modérateur".uppercased()
        
      case .member:
        self.memberRoleLabel.text = "membre".uppercased()
        
      case .spectator:
        self.memberRoleLabel.text = "spectateur".uppercased()
        
      case .banned:
        self.navigationController?.popViewController(animated: true)
      }
      
    }
    
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Actions & Intents
  
  @IBAction func changeRoleAction(_ sender: Any) {
    
  }
    
  @IBAction func warnAction(_ sender: Any) {
    let alertView = AlertViewWithField.loadFromXib()
    alertView?.create(title: "Envoyer un Warning",
                      placeholder: "Raison du warning...",
                      okCompletionHandler: { self.warnSubject.onNext(alertView?.textField.text)})
    alertView?.show(viewController: self)
  }
    
  @IBAction func banAction(_ sender: Any) {
    let alertView = AlertViewWithField.loadFromXib()
    alertView?.create(title: "Bannir \(username!)",
                      placeholder: "Raison du ban...",
                      okCompletionHandler: { self.banSubject.onNext(alertView?.textField.text)})
    alertView?.show(viewController: self)
  }
    
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "discussSegue" {
      let chatViewController = segue.destination as! MessagingViewController
      chatViewController.context = .chat
      chatViewController.contextId = ""
    }
  }
    
}

// -------------------------------------------------------------------------------------------------

// MARK - UI Picker Datasource & Delegate Methods

extension MemberDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource{
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 4
  }
  
//  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//    return Role(hashValue: row)?.description
//  }
//
//  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//    self.changeRoleButton.titleLabel?.text = Role(rawValue: row)?.description.uppercased()
//    self.changeRoleSubject.onNext(Role(rawValue: row)!)
//  }
//
//  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//    let label = (view as? UILabel) ?? UILabel()
//    label.font = UIFont(name: "Roboto-Bold", size: 18)
//    label.textAlignment = .center
//    label.textColor = UIColor.white
//    label.text = Role(rawValue: row)!.description.uppercased()
//    return label
//  }
  
}
