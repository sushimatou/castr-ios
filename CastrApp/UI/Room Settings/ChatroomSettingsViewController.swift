//
//  ChatroomSettingsViewController.swift
//  CastrApp
//
//  Created by Antoine on 01/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

class ChatroomSettingsViewController: UIViewController {
  
  // MARK: - IB Outlets
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var chatroomNameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var photoLabel: UILabel!
  @IBOutlet weak var changeColorButton: RoundedButton!
  @IBOutlet weak var closeChatroomButton: UIButton!
  @IBOutlet weak var membersButton: UIButton!
  @IBOutlet weak var picView: UIImageView!
  @IBOutlet weak var changePicButton: UIButton!
  @IBOutlet weak var saveButton: RoundedButton!
  @IBOutlet weak var chatroomNameTextField: UITextField!
  @IBOutlet weak var descriptionTextField: UITextField!
  @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    
  // MARK: - Properties
  
  let imagePicker = UIImagePickerController()
  let disposeBag = DisposeBag()
  let changePicSubject = PublishSubject<String>()
  var infos: ChatroomDTO!
  var initName: String?
  var initDescription: String?
  
  // MARK: - Life Cycle Methods
  
  override func viewDidLoad() {
    updateInfos(infos: infos)
    obsKeyboard()
    initName = infos.name
    initDescription = infos.description
    saveButton.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    ChatroomSettingsPresenter.instance.bind(view: self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    ChatroomSettingsPresenter.instance.unbind()
  }
  
  // MARK: - Intents & Actions
  
  func changeNameIntent() -> Observable<String> {
    return self
      .chatroomNameTextField
      .rx
      .text
      .orEmpty
      .asObservable()
  }
  
  func changeDescriptionIntent() -> Observable<String> {
    return self
      .descriptionTextField
      .rx
      .text
      .orEmpty
      .asObservable()
  }
  
  func changeColorIntent() -> Observable<Int> {
    return self
      .changeColorButton
      .rx
      .tap
      .asObservable()
      .map{ _ in
        let color = ColorGeneratorHelper.getRandomColor()
        return color
    }
  }
  
  func saveIntent() -> Observable<(name: String?, description: String?)> {
    return self
      .saveButton
      .rx
      .tap
      .map{_ in
        return (name: self.chatroomNameTextField.text, description: self.descriptionTextField.text)
    }
  }
  
  @IBAction func closeChatroomAction(_ sender: Any) {
    let alertView = AlertView.loadFromXib()
    alertView?.create(title: "Fermer la chatroom", text: "Voulez-vous vraiment fermer cette chatroom ?",
                      okCompletionHandler: {
                        
    }, withCancelButton: true)
    alertView?.show(viewController: self)
  }
    
  // MARK: - Keyboard Obs
    
  func obsKeyboard() {
    
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { keyboardVisibleHeight in
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0) {
          self.scrollView.contentInset.bottom = keyboardVisibleHeight + self.saveButton.frame.height
          self.scrollView.scrollIndicatorInsets.bottom = keyboardVisibleHeight + self.saveButton.frame.height
          print(self.saveButtonBottomConstraint.constant)
          self.saveButtonBottomConstraint.constant = 20 + keyboardVisibleHeight
          self.view.layoutIfNeeded()
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Render Methods
  
  func render(state: ChatroomSettingsViewState) {
    
    self.chatroomNameTextField.callbackWithState(state: state.nameState)
    self.descriptionTextField.callbackWithState(state: state.descriptionState)
    
    if state.color != nil {
      updateColor(color: state.color!)
    }
    
    if case FieldState.valid = state.nameState,
       case FieldState.valid = state.descriptionState {
         self.saveButton.isHidden = false
         self.saveButton.isEnabled = true
    }
    else if case FieldState.valid = state.nameState,
      case FieldState.pristine = state.descriptionState {
      self.saveButton.isHidden = false
      self.saveButton.isEnabled = true
    }
    else if case FieldState.pristine = state.nameState,
      case FieldState.valid = state.descriptionState {
      self.saveButton.isHidden = false
      self.saveButton.isEnabled = true
    }
    else if case FieldState.pristine = state.nameState,
      case FieldState.pristine = state.descriptionState {
      self.saveButton.isHidden = true
    }
    else {
      self.saveButton.isHidden = false
      self.saveButton.isEnabled = false
    }
  
  }
    
  func updateInfos(infos: ChatroomDTO){
    self.chatroomNameTextField.text = infos.name
    self.navigationController?.navigationBar.tintColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: infos.color))
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(hex: ColorGeneratorHelper.getColorwithId(id: infos.color))]
    self.saveButton.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: infos.color))
    self.chatroomNameLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: infos.color))
    self.descriptionLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: infos.color))
    self.photoLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: infos.color))
    self.descriptionTextField.text = infos.description
    self.changeColorButton.imageView?.tintColor = UIColor(hex: ColorGeneratorHelper
      .getColorwithId(id: infos.color))
    self.picView.backgroundColor = UIColor(hex: ColorGeneratorHelper
      .getColorwithId(id: infos.color))
  }
  
  func updateColor(color: Int){
    self.navigationController?.navigationBar.tintColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: color))
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(hex: ColorGeneratorHelper.getColorwithId(id: color))]
    self.saveButton.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: color))
    self.chatroomNameLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: color))
    self.descriptionLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: color))
    self.photoLabel.textColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: color))
    self.changeColorButton.imageView?.tintColor = UIColor(hex: ColorGeneratorHelper
      .getColorwithId(id: color))
    self.picView.backgroundColor = UIColor(hex: ColorGeneratorHelper
      .getColorwithId(id: color))
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    switch segue.identifier {
    
    case "membersSegue"?:
      let membersViewController = segue.destination as! MembersViewController
      membersViewController.chatroomId = self.infos.id
      
    case "changePicSegue"?:
      let changePicVC = segue.destination as! ChangePictureViewController
      changePicVC.context = .chatroomPic(infos, ref: self)
      
    default:
      break
      
    }
  }
}

// -------------------------------------------------------------------

// MARK: - UIImagePickerControllerDelegate Methods

extension ChatroomSettingsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      picView.contentMode = .scaleAspectFit
      picView.image = pickedImage
    }
    dismiss(animated: true, completion: nil)
  }
  
  private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
}
