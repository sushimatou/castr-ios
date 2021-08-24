//
//  ChatroomViewController.swift
//  CastrApp
//
//  Created by Antoine on 17/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import DeckTransition

class MessagingViewController: UIViewController, UINavigationControllerDelegate {
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - IB Outlets
  
  @IBOutlet weak var messagingStackView: UIStackView!
  @IBOutlet weak var toolbar: UIView!
  @IBOutlet weak var waitingView: UIView!
  @IBOutlet weak var messageTextView: UITextView!
  @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var shareButton: UIButton!
  @IBOutlet weak var inviteButton: CircularButton!
  @IBOutlet weak var infosButton: UIButton!
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var messagesTableView: UITableView!
  @IBOutlet weak var longPressGesture: UILongPressGestureRecognizer!
  @IBOutlet weak var sendMessageButton: RoundedButton!
  @IBOutlet weak var deleteImageButton: CircularButton!
  @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Properties
  
  let disposeBag = DisposeBag()
  let reportSubject = PublishSubject<(messageId: String, reason: String?)>()
  let blockSubject = PublishSubject<String>()
  let unblockSubject = PublishSubject<String>()
  let imageSubject = PublishSubject<[String:Any]>()
  let addLoveSubject = PublishSubject<[String:Any]>()
  let addPhotoSubject = PublishSubject<UIImage>()
  let loadMoreSubject = PublishSubject<String>()
  var messageImageView : UIImageView?
  
  lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = false
    imagePicker.modalPresentationStyle = .popover
    return imagePicker
  }()
  
  var photoBuffer: [UIImage] = []
  var profile: UserDTO?
  var canLoadMore: Bool = false
  var isRendering: Bool = true
  var isAtTop = false
  var datesSections = [String]()
  var messages = [MessageDto]()
  var groupedMessages = [String : [MessageDto]]()
  var infos : MessagingInfos?
  var user: UserDTO?
  var obsAddLoves : Disposable? = nil
  var loveAmount: Int? = nil
  var contextId = String()
  var chatroomColor = Int()
  var chatroomName = String()
  var disposable : Disposable?
  var context: MessagingContext?
  var previousState = MessagingViewState()
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Lifecycle Methods
  
  override func viewDidLoad() {
    self.toolbar.layoutSubviews()
    self.textEditIntent().subscribe()
    self.messageTextView.placeholder = "Votre message..."
    self.toolbar.frame.size.height = 50
    self.toolbar.layoutIfNeeded()
    self.deleteImageButton.isHidden = true
    self.messageTextView.tintColor = .white
    self.messagesTableView.estimatedRowHeight = 100.0
    self.messagesTableView.rowHeight = UITableViewAutomaticDimension
    self.obsKeyboard()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    MessagingPresenter.getPresenter(contextId: contextId)
      .bind(view: self, context: context!)
    photoBuffer.forEach { (image) in
      addPhotoSubject.onNext(image)
    }
    photoBuffer = []
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    MessagingPresenter.getPresenter(contextId: contextId)
      .unbind()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Intents
  
  func sendMessageIntent() -> Observable<(text: String?, image: Data?)> {
    return sendMessageButton
      .rx
      .tap
      .asObservable()
      .map{ _ in
        let text = self.messageTextView.text
        self.messageTextView.text = nil
        if self.messageImageView != nil {
          let image = self.messageImageView!.image
          let data = UIImageJPEGRepresentation(image!, 0.6)
          return (text: text, image: data)
        } else {
          return (text: text, image: nil)
        }
      }
  }
  
  func addOrRemoveFavoriteIntent() -> Observable<Bool> {
    return self.favoriteButton
      .rx
      .tap
      .map{_ in
        return self.favoriteButton.isSelected
    }
  }
  
  func textEditIntent() -> Observable<String> {
    return messageTextView
      .rx
      .text
      .orEmpty
      .map{ text in
        self.sendMessageButton.isEnabled = text.count > 0
        let sizeThatFitsTextView = self
          .messageTextView
          .sizeThatFits(
            CGSize(width: self.messageTextView.frame.size.width,
                   height: 90))
        self.messageTextViewHeightConstraint.constant = sizeThatFitsTextView.height + 5
        return text
      }
  }
  
  func clearPhotoIntent() -> Observable<Void> {
    return deleteImageButton
      .rx
      .tap
      .map{}
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK : - Reactive Keyboard
  
  func obsKeyboard() {
    
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { keyboardVisibleHeight in
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0) {
          self.messagesTableView
            .contentInset
            .bottom = keyboardVisibleHeight + self.toolbar.frame.height
          self.messagesTableView
            .scrollIndicatorInsets
            .bottom = keyboardVisibleHeight + self.toolbar.frame.height
          print(self.toolbarBottomConstraint.constant)
          self.toolbarBottomConstraint.constant = 1 * keyboardVisibleHeight
          self.view.layoutIfNeeded()
        }
      })
      .disposed(by: disposeBag)
    
    RxKeyboard.instance.willShowVisibleHeight
      .drive(onNext: { keyboardVisibleHeight in
        self.messagesTableView.contentOffset.y += keyboardVisibleHeight + self.toolbar.frame.height
        self.messagesTableView
          .contentInset
          .bottom = keyboardVisibleHeight + self.toolbar.frame.height
      })
      .disposed(by: disposeBag)
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Render Methods
  
  func render(state: MessagingViewState) {
    
    self.isRendering = true
    self.messages = state.messages
    self.groupedMessages = state.groupedMessages
    self.datesSections = state.datesSections
    self.isAtTop = state.isAtTop
    self.infos = state.infos
    self.messagesTableView.reloadData()
    
    if state.profile != nil {
      self.profile = state.profile
    }
    
    if state.isNewPage {
      self.updateWithContentOffset()
    }
    
    if state.shouldScrollToBottom {
      self.shouldScrollToBottom()
    }
    
    if state.reported != nil {
      self.messageReported(reported: state.reported!)
    }
    
    if state.blocked != nil {
      self.userBlocked(blocked: state.blocked!)
    }
    
    if state.unblocked != nil {
      self.userUnblocked(unblocked: state.unblocked!)
    }

    self.displayHeaderView(isAtTop: state.isAtTop)
    
    if state.media != nil {
      self.createImageView()
      self.messageImageView!.image = state.media
      self.deleteImageButton.isHidden = false
      
    } else {
      self.deleteImageView()
    }
    
    // infos
    
    if let newInfos = state.infos {
      self.infos = newInfos
      renderChatroomStyle(infos: newInfos)
      
      switch newInfos {
        
      case .chat(_):
        self.settingsButton.isHidden = true
        self.inviteButton.isHidden = true
        self.infosButton.isHidden = true
        self.favoriteButton.isHidden = true
        self.shareButton.isHidden = true
        
      case .chatroom(let chatroomInfos):
        self.contextId = chatroomInfos.id
        self.favoriteButton.isSelected = chatroomInfos.isFavorite
        switch chatroomInfos.role! {
        case .admin:
          self.settingsButton.isHidden = false
          self.toolbar.isHidden = false
          
        case .moderator:
          self.settingsButton.isHidden = false
          self.toolbar.isHidden = false
          
        case .member:
          self.settingsButton.isHidden = true
          self.toolbar.isHidden = false
          
        case .spectator:
          self.settingsButton.isHidden = true
          self.toolbar.isHidden = true
          
        case .banned:
          self.getBanned()
        }
      }
    }
    
    if let error = state.error {
      switch error {
      case .banned:
        getBanned()
      default:
        break
      }
    }

    self.canLoadMore = !state.isLoading && !state.isLoadingMore
    previousState = state
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + 0.35 ,
      execute: {
        self.waitingView.isHidden = !state.isLoading
        self.isRendering = false
    })
  }
  
  func renderChatroomStyle(infos: MessagingInfos){
    switch infos {
    case .chat(let chatInfos):
      self.title = chatInfos.name
      self.chatroomName = chatInfos.name
      self.chatroomColor = chatInfos.color
      navigationController?
        .navigationBar
        .tintColor = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: chatInfos.color))
      navigationController?
        .navigationBar
        .titleTextAttributes = [NSForegroundColorAttributeName: UIColor(hex: ColorGeneratorHelper.getColorwithId(id: chatInfos.color))]
      navigationController?.navigationBar.tintColorDidChange()
      
      
    case .chatroom(let chatroomInfos):
      self.title = chatroomInfos.name
      self.contextId = chatroomInfos.id
      self.chatroomName = chatroomInfos.name
      let color = UIColor(hex: ColorGeneratorHelper.getColorwithId(id: chatroomInfos.color))
      navigationController?
        .navigationBar
        .tintColor = color
      navigationController?
        .navigationBar
        .titleTextAttributes = [NSForegroundColorAttributeName: color]
      navigationController?.navigationBar.tintColorDidChange()
    }
  }
  
  func updateWithContentOffset() {
    if self.messages.count > 20 {
      messagesTableView.reloadData()
      var rowCount = 0
      for section in 0...self.messagesTableView.numberOfSections - 1 {
        if self.messagesTableView.numberOfRows(inSection: section) > 1{
          for row in 0...self.messagesTableView.numberOfRows(inSection: section) - 1 {
            rowCount += 1
            if rowCount == 20 {
              let indexPath = IndexPath(row: row, section: section)
              messagesTableView.scrollToRow(at: indexPath, at: .top, animated: false)
              break
            }
          }
        }
      }
    }
  }
  
  func createImageView() {
    if messageImageView == nil {
      self.messageImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
      self.messageImageView!.contentMode = .scaleAspectFill
      self.messageImageView!.clipsToBounds = true
      self.messageImageView!.layer.cornerRadius = 10
      let widthCst = NSLayoutConstraint(item: self.messageImageView!, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200)
      self.messageImageView!.addConstraint(widthCst)
      self.messagingStackView.insertArrangedSubview(self.messageImageView!, at: 0)
      self.deleteImageButton.isHidden = false
      self.toolbar.sizeToFit()
    }
  }
  
  func deleteImageView() {
    if self.messageImageView != nil {
      self.messagingStackView.removeArrangedSubview(self.messageImageView!)
      self.messageImageView = nil
      self.deleteImageButton.isHidden = true
      self.toolbar.sizeToFit()
    }
  }
  
  func getBanned() {
    let alertView = AlertView.loadFromXib()
    alertView?.create(title: "Banni", text: "Vous avez été banni de la chatroom.", withCancelButton: false)
    alertView?.show(viewController: self)
    self.navigationController?.popViewController(animated: true)
  }
  
  func messageReported(reported: Bool){
    let alertView = AlertView.loadFromXib()
    if reported {
      alertView?.create(title: "Message signalé", text: "Le message a été signalé à l'administrateur.", withCancelButton: false)
    }
    else {
      alertView?.create(title: "Erreur", text: "Impossible de signaler le message. Réessayez ultérieurement.", withCancelButton: false)
    }
    alertView?.show(viewController: self)
  }
  
  func userBlocked(blocked: Bool){
    let alertView = AlertView.loadFromXib()
    if blocked {
      alertView?.create(title: "Utilisateur bloqué", text: "Cet utilisateur a été bloqué. Vous ne verrez plus ses messages.", withCancelButton: false)
    }
    else {
      alertView?.create(title: "Erreur", text: "Impossible de bloquer cet utilisateur. Réessayez ultérieurement.", withCancelButton: false)
    }
    alertView?.show(viewController: self)
  }
  
  func userUnblocked(unblocked: Bool){
    let alertView = AlertView.loadFromXib()
    if unblocked {
      alertView?.create(title: "Utilisateur débloqué", text: "Cet utilisateur a été débloqué.", withCancelButton: false)
    }
    else {
      alertView?.create(title: "Erreur", text: "Impossible de débloquer cet utilisateur. Réessayez ultérieurement.", withCancelButton: false)
    }
    alertView?.show(viewController: self)
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Navigation
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if case MessagingContext.chatroom = self.context! {
      return true
    } else {
      return false
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if self.infos != nil {
    
    if case MessagingInfos.chatroom(let chatroom) = self.infos! {
      switch segue.identifier {
        
      case "chatroomInfosSegue"?:
        let chatroomInfosViewController = segue.destination as! ChatroomInfosViewController
        chatroomInfosViewController.infos = chatroom
      
      case "settingsSegue"?:
      
        let settingsViewController = segue.destination as! ChatroomSettingsViewController
        settingsViewController.infos = chatroom
      
      case "messageModalSegue"?:
      
        let selectedIndexPath = self.messagesTableView.indexPathForSelectedRow
        let dateSection = self.datesSections[selectedIndexPath!.section]
        let message = self.groupedMessages[dateSection]![selectedIndexPath!.row]
      
        if case MessageType.userMessage(let userMessage) = message.type{
          let messageModalViewController = segue.destination as! MessageModalViewController
          messageModalViewController.delegate = self
          messageModalViewController.message = userMessage
          messageModalViewController.chatroomId = self.contextId
          messageModalViewController.otherUserId = userMessage.authorId
          messageModalViewController.role = chatroom.role
        }
      default:
        break
      }
      }
    }
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Local Actions
  
  @IBAction func shareAction(_ sender: Any) {
    let shareText = "Viens parler sur la room \(title!) avec moi ! \(Config.wsEndPoint)/chatroom/\(contextId)"
    let vc = UIActivityViewController(
      activityItems:[shareText],applicationActivities: [])
    present(vc, animated: true)
  }
  
  @IBAction func sendImageAction(_ sender: Any) {
    let alertView = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertView.addAction(UIAlertAction(title: "Choisir une photo", style: .default, handler: { (_) in
      self.imagePicker.sourceType = .photoLibrary
      self.present(self.imagePicker, animated: true, completion: nil)
    }))
    alertView.addAction(UIAlertAction(title: "Prendre une photo", style: .default, handler: { (_) in
      self.imagePicker.sourceType = .camera
      self.imagePicker.cameraCaptureMode = .photo
      self.present(self.imagePicker, animated: true, completion: nil)
    }))
    alertView.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (_) in
      self.dismiss(animated: true, completion: nil)
    }))
    self.present(alertView, animated: true, completion: nil)
  }
  
  @IBAction func addLoveAction(_ sender: Any) {
    
    let touchPoint = longPressGesture.location(in: self.messagesTableView)
    let selectedIndexPath = self.messagesTableView.indexPathForRow(at: touchPoint)
    let dateSection = self.datesSections[selectedIndexPath!.section]
    let selectedMessage = self.groupedMessages[dateSection]![selectedIndexPath!.row]
    
    if case MessageType.userMessage(let userMessage) = selectedMessage.type {
      var userMessage = userMessage
      let msgId = userMessage.msgId
      if !userMessage.isOwn && longPressGesture.state == .began && self.obsAddLoves == nil {
        self.loveAmount = 0
        self.obsAddLoves = Observable<Int>
          .interval(0.5, scheduler: MainScheduler.instance)
          .subscribe { _ in
            userMessage.love += 1
            self.loveAmount! += 1
            self.groupedMessages[dateSection]![selectedIndexPath!.row] = MessageDto(id: msgId, type: MessageType.userMessage(message: userMessage))
            self.messagesTableView.reloadRows(at: [selectedIndexPath!], with: .none)
        }
      }
      
      if longPressGesture.state == .ended && self.obsAddLoves != nil {
        self.addLoveSubject.onNext(
          ["message_id" : msgId,
           "loveAmount" : self.loveAmount!])
        self.obsAddLoves!.dispose()
        self.obsAddLoves = nil
        self.loveAmount = nil
      }
    }
  }
}

// -------------------------------------------------------------------------------------------------

// MARK: - ScrollView Delegate Methods

extension MessagingViewController: UIScrollViewDelegate {
  
  func shouldScrollToBottom() {
    if self.messages.count > 0 {
      DispatchQueue.main.async {
        let index = IndexPath(
          row: self.groupedMessages[self.datesSections.last!]!.count - 1,
          section: self.datesSections.count - 1)
          self.messagesTableView.scrollToRow(at: index, at: .bottom, animated: true)
    }
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffset = Double(scrollView.contentOffset.y)
    let threshold = 10.0
    if !self.isRendering && self.canLoadMore && (contentOffset - threshold <= 0) && !self.isAtTop {
      self.canLoadMore = false
      let lastMsgId = self.messages.first?.id
      if lastMsgId != nil {
        print("load more subject")
        self.loadMoreSubject.onNext(lastMsgId!)
      }
    }
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
      self.shareButton.alpha = 0
      self.inviteButton.alpha = 0
      self.settingsButton.alpha =  0
      self.favoriteButton.alpha =  0
      self.infosButton.alpha =  0
    }, completion: nil)
  }
  
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseOut, animations: {
      self.shareButton.alpha = 1.0
      self.inviteButton.alpha = 1.0
      self.settingsButton.alpha = 1.0
      self.favoriteButton.alpha = 1.0
      self.infosButton.alpha = 1.0
    }, completion: nil)
  }
}

// -------------------------------------------------------------------------------------------------

// MARK: - ImagePicker Delegate Methods

extension MessagingViewController: UIImagePickerControllerDelegate {
  
  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      photoBuffer.append(pickedImage)
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  internal func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Detail Modal Delegate Methods

extension MessagingViewController: MessageDetailViewControllerDelegate {
  
  func didTapReportUser(sender: MessageModalViewController, messageId: String) {
    let alertView = AlertViewWithField.loadFromXib()
    alertView?.create(title: "Signaler le message", placeholder: "Raison", okCompletionHandler: {
      self.reportSubject.onNext((messageId: messageId, reason: alertView?.textField.text))
    })
    alertView?.show(viewController: self)
  }
  
  func didTapBlockUser(sender: MessageModalViewController, authorId: String) {
    self.blockSubject.onNext(authorId)
  }
  
  func didTapUnblockUser(sender: MessageModalViewController, authorId: String) {
    self.unblockSubject.onNext(authorId)
  }
  
}

// -------------------------------------------------------------------------------------------------

// MARK: - TableView Datasource & Delegate Methods

extension MessagingViewController: UITableViewDelegate, UITableViewDataSource {
  
  // Cell Dequeue
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let dateSection = self.datesSections[indexPath.section]
    let messageAtIndexPath = self.groupedMessages[dateSection]![indexPath.row]
    
    switch messageAtIndexPath.type {
      
    case .infoMessage(_):
      let cell = UITableViewCell()
      return cell
      
    case .botMessage(let type):
      
      switch type {
        
      case .text(_):
        let cell = tableView
          .dequeueReusableCell(withIdentifier: "CastrBotCellId") as! CastrBotTableViewCell
        cell.type = type
        return cell
        
      case .set:
        let cell = tableView
          .dequeueReusableCell(withIdentifier: "CastrBotButtonCellId") as! CastrBotButtonTableViewCell
        cell.button.imageView?.image = #imageLiteral(resourceName: "Settings")
        cell.button.titleLabel?.text = "Configurer"
        return cell
        
      case .invite:
        let cell = tableView.dequeueReusableCell(withIdentifier: "CastrBotButtonCellId") as! CastrBotButtonTableViewCell
        cell.button.imageView?.image = #imageLiteral(resourceName: "Add People Icon")
        cell.button.titleLabel?.text = "Inviter"
        return cell
        
      }
      
    case .userMessage(let message):
      
      if message.isOwn {
        let cell = tableView
          .dequeueReusableCell(withIdentifier: "SelfMessageCellId", for: indexPath) as! SelfMessageTableViewCell
        cell.message = message
        return cell
      } else {
        let cell = tableView
          .dequeueReusableCell(withIdentifier: "MessageCellId", for: indexPath) as! MessageTableViewCell
        cell.message = message
        if indexPath.row >= 1 {
          if let previousMessage = self.groupedMessages[dateSection]?[indexPath.row-1] {
            if case MessageType.userMessage(let previousUserMessage) = previousMessage.type {
              cell.previousMessage = previousUserMessage
            }
          }
        }
        if (self.profile?.blackList.contains(where: { (id) -> Bool in
          return message.authorId == id
        }))! {
          cell.message.type = UserMessageDto.MessageType.blocked
        }
        return cell
      }
    }
  }
  
  // Sections
  
  func numberOfSections(in tableView: UITableView) -> Int {
    print("numberOfSections: ", self.datesSections.count)
    return self.datesSections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let dateSection = self.datesSections[section]
    return self.groupedMessages[dateSection]!.count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerSectionView = Bundle.main.loadNibNamed("MessagingHeaderSectionView", owner: nil, options: [:])!.first as! MessagingHeaderSectionView
    headerSectionView.dateStr = self.datesSections[section]
    return headerSectionView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  func displayHeaderView(isAtTop: Bool) {
    if isAtTop {
      let welcomeView = Bundle.main.loadNibNamed("MessagingHeaderView", owner: nil, options: [:])?.first as! MessagingHeaderView
      welcomeView.infos = self.infos
      self.messagesTableView.tableHeaderView = welcomeView
    } else {
      let spinner = UIActivityIndicatorView()
      spinner.startAnimating()
      self.messagesTableView.tableHeaderView = spinner
    }
  }
}
