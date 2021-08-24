//
//  ProfileViewController.swift
//  CastrApp
//
//  Created by Castr on 20/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Hex
import SDWebImage


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
  // MARK: - IB Outlets
    
  // For All
    
  @IBOutlet weak var waitingView: UIView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var profilePicImageView: UIImageView!
  @IBOutlet weak var messagesCountLabel: UILabel!
  @IBOutlet weak var lovesCountLabel: UILabel!
    
  // For Anonymous Users
    
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var generateNameButton: UIButton!
  @IBOutlet weak var generateColorButton: UIButton!
    
  // For Connected Users
  
  @IBOutlet weak var changeNameButton: RoundedButton!
  @IBOutlet weak var changePicButton: UIButton!
  @IBOutlet weak var disconnectButton: RoundedButton!
  
  // -----------------------------------------------------------------------------------------------
    
  // MARK: - Properties
  
  let imagePicker = UIImagePickerController()
  let changeNameSubject = PublishSubject<String>()
  let logOutSubject = PublishSubject<Void>()
  var user : UserDTO?
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Life Cycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imagePicker.delegate = self
    navigationItem.titleView = UIImageView.init(image: #imageLiteral(resourceName: "Profil Color"))
  }
  
  override func viewWillAppear(_ animated: Bool) {
    ProfilePresenter.instance.bind(view: self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    ProfilePresenter.instance.unbind(view: self)
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Intents & Actions Methods
  
  func genNewColorIntent() -> Observable<Int>{
    
    return generateColorButton.rx
      .tap
      .asObservable()
      .map{ ignored in
        let color = ColorGeneratorHelper.getRandomColor()
        self.stylize(color: color)
        return color
    }
  }
  
  func genNewNameIntent() -> Observable<Void>{
    return generateNameButton.rx
      .tap
      .asObservable()
  }
    
  @IBAction func logOutAction(_ sender: Any) {
    let alertView = AlertView.loadFromXib()
    alertView!.create(title: "Déconnexion",
                      text: "Voulez-vous vraiment vous déconnecter ?",
                      okCompletionHandler: {_ in
                        self.logOutSubject.onNext(())
                      },
                      withCancelButton: true)
    alertView!.show(viewController: self)
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Render Methods
  
  func render(state: ProfileViewState){
    
    switch state {
      
    case .isLoading:
      self.waitingView.isHidden = false
    
    case .error(let error):
      self.renderError(error)
      
    case .profile(let user):
      self.waitingView.isHidden = true
      self.renderProfile(user)
      
    }
  }
  
  func renderProfile(_ user: UserDTO) {
    print("user vc - redering")
    self.user = user
    self.usernameLabel.text = user.name
    self.messagesCountLabel.text = "\(user.messages)"
    self.lovesCountLabel.text = "\(user.loves)"
    self.changePicButton.isHidden = !user.isRegistered
    self.changeNameButton.isHidden = !user.isRegistered
    self.generateNameButton.isHidden = user.isRegistered
    self.disconnectButton.isHidden = !user.isRegistered
    self.signInButton.isHidden = user.isRegistered
    self.signUpButton.isHidden = user.isRegistered
    
    if let picture = user.picture {
      self.profilePicImageView.sd_setImage(with: URL(string: picture), completed: nil)
      self.profilePicImageView.clipsToBounds = true
    }
    else {
      self.profilePicImageView.image = nil
    }
    
    self.stylize(color: user.color)
  }
  
  func renderError(_ error: CastrError) {
    
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - UI Stylizing
  
  func stylize(color: Int){
    
    let colorSet = ColorGeneratorHelper.getColorwithId(id: color)
    self.messagesCountLabel.textColor = UIColor(hex: colorSet)
    self.lovesCountLabel.textColor = UIColor(hex: colorSet)
    self.signUpButton.backgroundColor = UIColor(hex: colorSet)
    self.profilePicImageView.backgroundColor = UIColor(hex: colorSet)
    self.generateColorButton.imageView?.tintColor = UIColor(hex: colorSet)
    
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
      
    case "changeNameSegue"?:
      let changeNameVC = segue.destination as! ChangeNameViewController
      changeNameVC.actualName = usernameLabel.text!
      
    case "changePicSegue"?:
      let changePicVC = segue.destination as! ChangePictureViewController
      changePicVC.context = .userPic(self.user!, ref: self)
      
    default:
      break
    }
  }
}


