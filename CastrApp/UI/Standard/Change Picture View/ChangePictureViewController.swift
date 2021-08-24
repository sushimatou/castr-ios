//
//  ChangePictureViewController.swift
//  CastrApp
//
//  Created by Antoine on 25/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import Hex

class ChangePictureViewController: UIViewController, UINavigationControllerDelegate {
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK - IBOutlets
  
  @IBOutlet weak var pictureUploadProgressView: UIProgressView!
  @IBOutlet weak var picView: CircularImageView!
  @IBOutlet weak var takePhotoButton: RoundedButton!
  @IBOutlet weak var choosePhotoButton: RoundedButton!
  @IBOutlet weak var deletePhotoButton: RoundedButton!
  @IBOutlet weak var changePictureButton: RoundedButton!
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Properties

  let addImageSubject = PublishSubject<UIImage>()
  var image: UIImage?
  var imageBuffer: [UIImage] = []
  var context: PictureContext!
  
  lazy var imagePicker : UIImagePickerController = {
    let picker = UIImagePickerController()
    picker.delegate = self
    return picker
  }()
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.imagePicker.delegate = self
    self.stylize(context: self.context)
    self.changePictureButton.isHidden = true
    self.pictureUploadProgressView.isHidden = true
    self.deletePhotoButton.isHidden = self.image == nil
  }
  
  override func viewWillAppear(_ animated: Bool) {
    ChangePicturePresenter.instance.bind(view: self)
    imageBuffer.forEach { (image) in
      addImageSubject.onNext(image)
    }
    imageBuffer = []
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    ChangePicturePresenter.instance.unbind()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Intents
  
  func validChangeIntent() -> Observable<UIImage> {
    return changePictureButton
      .rx
      .tap
      .map{ _ in
        return self.picView.image!
    }
  }
  
  func deleteImageIntent() -> Observable<Void> {
    return deletePhotoButton
      .rx
      .tap
      .asObservable()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Actions
  
    @IBAction func takePictureAction(_ sender: Any) {
      self.imagePicker.allowsEditing = true
      self.imagePicker.sourceType = .camera

      self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePictureAction(_ sender: Any) {
      self.imagePicker.allowsEditing = true
      self.imagePicker.sourceType = .photoLibrary
      self.present(self.imagePicker, animated: true, completion: nil)
      
    }
    
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Render
  
  func render(state: ChangePictureViewState){
    switch state {
    case .empty(let media):
      self.picView.image = media
      self.picView.layer.cornerRadius = self.picView.frame.size.height / 2
      self.picView.clipsToBounds = true
      self.changePictureButton.isHidden = media == nil
      
    case .uploading(let progress):
      self.pictureUploadProgressView.isHidden = false
      self.changePictureButton.isEnabled = false
      self.pictureUploadProgressView.progress = Float(progress.completedUnitCount * 100 / progress.totalUnitCount)
      
    case .uploaded:
      self.returnToProfile(image: self.picView.image)
    
    case .error(_):
      break
      
    }
    self.changePictureButton.isEnabled = self.picView.image != nil
  }
  
  func returnToProfile(image: UIImage?) {
    switch self.context! {

    case .chatroomPic(_, let chatroomSettingsViewController):
      chatroomSettingsViewController.picView.image = image
      chatroomSettingsViewController.picView.clipsToBounds = true
      self.navigationController?.popViewController(animated: true)

    case .userPic(_, let profileViewController):
      profileViewController.profilePicImageView.image = image
      profileViewController.profilePicImageView.clipsToBounds = true
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  func stylize(context: PictureContext) {
    switch context {
    case .userPic(let user,_):
      self.picView.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: user.color))
    case .chatroomPic(let chatroom, _):
      self.picView.backgroundColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: chatroom.color))

    }
  }
}

// -------------------------------------------------------------------------------------------------

// MARK: - UIImagePicker Controller Delegate

extension ChangePictureViewController : UIImagePickerControllerDelegate {
  
  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    if #available(iOS 11.0, *) {
      if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
        imageBuffer.append(image)
      }
      dismiss(animated: true, completion: nil)
    }
      
    else {
      // todo < 11.0
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
}

// -------------------------------------------------------------------------------------------------

// MARK: - Context Enum

enum PictureContext {
  case chatroomPic(_: ChatroomDTO, ref: ChatroomSettingsViewController)
  case userPic(_: UserDTO, ref: ProfileViewController)
}
