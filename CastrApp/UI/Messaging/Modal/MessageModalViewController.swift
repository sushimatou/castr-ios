//
//  CreateChatroomViewController.swift
//  CastrApp
//
//  Created by Antoine on 26/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxSwift
import DeckTransition

// TODO - Use for all actions in modals

protocol MessageDetailViewControllerDelegate: NSObjectProtocol {
  func didTapReportUser(sender: MessageModalViewController, messageId: String)
  func didTapBlockUser(sender: MessageModalViewController, authorId: String)
  func didTapUnblockUser(sender: MessageModalViewController, authorId: String)
}

class MessageModalViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    // NOOP
  }
  
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var containerView: UIView!
    
  // Message body

  @IBOutlet weak var webViewContainerView: UIView!
  @IBOutlet weak var messagePicView: UIImageView!
  @IBOutlet weak var messageView: UIView!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var lovesIcon: UIImageView!
  @IBOutlet weak var lovesCountLabel: UILabel!
  @IBOutlet weak var timerLabel: UILabel!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var picView: UIImageView!
  @IBOutlet weak var messageStackView: UIStackView!
    
  // Buttons
  @IBOutlet weak var memberDetailButton: UIButton!
  @IBOutlet weak var deleteMessageButton: UIButton!
  @IBOutlet weak var blockButton: UIButton!
  @IBOutlet weak var discussButton: UIButton!
  @IBOutlet weak var reportButton: RoundedButton!
  @IBOutlet weak var unblockButton: RoundedButton!
  
  // MARK: - Properties
  weak var delegate: MessageDetailViewControllerDelegate?
  var messageWebView : WKWebView!
  var message : UserMessageDto!
  var chatroomId: String!
  var userId: String!
  var otherUserId: String!
  var role: Role!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.title = nil
    MessageModalPresenter.instance.bind(view: self)
    self.modalPresentationCapturesStatusBarAppearance = true
    self.modalPresentationStyle = .currentContext
    self.setupWebView()
    self.feedWithSegue()
  }
  
  func feedWithSegue(){
    
    self.webViewContainerView.isHidden = true
    self.messageLabel.isHidden = true
    self.messagePicView.isHidden = true
    self.unblockButton.isHidden = true
  
    switch message.type {
      
    case .text(let text):
      self.messageLabel.isHidden = false
      self.messageLabel.text = text
      
    case .media(let mediaWith, _ , let text):
      self.messagePicView.isHidden = false
      self.messageLabel.isHidden = text == nil
      self.messageLabel.text = text

      switch mediaWith {
      case .image(let image):
        self.messagePicView.image = image
      case .url(let url):
        self.messagePicView.sd_setImage(
          with: URL(string: url),
          placeholderImage: nil,
          options: [.continueInBackground, .progressiveDownload])
      }
      self.messageView.clipsToBounds = true
    
    case .embed(let text, let embed):
      
      self.messageLabel.isHidden = text == nil
      self.messageLabel.text = text
      self.webViewContainerView.isHidden = false
      if let contentHtml = embed.contentHtml {
        let embed = createHtml(embedHtml: contentHtml)
        self.messageWebView.loadHTMLString(embed, baseURL: nil)
      }
      self.webViewContainerView.clipsToBounds = true

    case .deleted:
      self.messageLabel.isHidden = false
      self.messageLabel.text = "Message supprimé"
      
    case .blocked:
      self.blockButton.isHidden = true
      self.unblockButton.isHidden = false
      self.messageLabel.text = "Utilisateur bloqué"
    default:
      break
    }
    
    if case Role.admin = self.role! {
      deleteMessageButton.isHidden = false
      memberDetailButton.isHidden = false
    } else {
      deleteMessageButton.isHidden = true
      memberDetailButton.isHidden = true
    }
    
    if message.authorPic != nil {
      self.picView.sd_setImage(
        with: URL(string: message.authorPic!),
        completed: nil)
      self.picView.clipsToBounds = true
    }
    
    let color = UIColor(hex: ColorGeneratorHelper .getColorwithId(id: message.color))
    self.lovesCountLabel.text = "\(message.love)"
    self.usernameLabel.text = message.author
    self.discussButton.setTitle("discuter avec \(message.author)".uppercased(), for: .normal)
    self.blockButton.setTitle("bloquer \(message.author)".uppercased(), for: .normal)
    self.unblockButton.setTitle("débloquer \(message.author)".uppercased(), for: .normal)
    self.reportButton.setTitle("signaler \(message.author)".uppercased(), for: .normal)
    self.picView.backgroundColor = color
    self.messageView.backgroundColor = color
    self.lovesIcon.tintColor = .darkGray
    self.timerLabel.text = "\(DateHelper.getTimeFromNow(interval: Double(message!.createdAt)))"
    
  }
  
  func render(state: MessageModalViewState){
    
    self.userId = state.userId!
    
    if state.deleted || state.blocked {
      self.closeModal()
    }
    
  }
  
  // MARK: - Intent
  
  func deleteMessageIntent() -> Observable<Void> {
    return deleteMessageButton
      .rx
      .tap
      .asObservable()
  }
    
  // MARK : - Actions
  
  @IBAction func detailAction(_ sender: Any) {
    if let memberDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "MemberDetailViewController") as? MemberDetailViewController {
        memberDetailViewController.username = self.message.author
        memberDetailViewController.chatroomId = self.chatroomId
        memberDetailViewController.userId = self.message.authorId
      self.dismiss(animated: true, completion: {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.visibleViewController?.show(memberDetailViewController, sender: nil)
      })
    }
  }
  
  @IBAction func discussAction(_ sender: Any) {
    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomViewController") as? MessagingViewController {
      if self.userId != nil {
      let usersIds = [self.userId, self.otherUserId].sorted(by: { (uid1, uid2) -> Bool in
        uid1! < uid2!
      })
      vc.contextId = "\(usersIds[0]!)-\(usersIds[1]!)"
      vc.context = .chat
      vc.chatroomName = self.message.author
        self.dismiss(animated: true, completion: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.visibleViewController?.show(vc, sender: nil)
        })
      }
    }
  }
    
  @IBAction func reportAction(_ sender: Any) {
    self.delegate?.didTapReportUser(sender: self, messageId: self.message.msgId)
    self.closeModal()
  }
  
  @IBAction func blockAction(_ sender: Any) {
    self.delegate?.didTapBlockUser(sender: self, authorId: self.message.authorId)
    self.closeModal()
  }
  
  @IBAction func unblockAction(_ sender: Any) {
    self.delegate?.didTapUnblockUser(sender: self, authorId: self.message.authorId)
    self.closeModal()
  }
  
  private func closeModal() {
    self.dismiss(animated: true, completion: nil)
  }
  
  
  
  
  private func setupWebView() {
    let webConfiguration = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    let js = "var iframe = document.querySelector('iframe'); iframe.setAttribute('width',\(Int(self.webViewContainerView.bounds.width))px; iframe.setAttribute('height',\(Int(self.webViewContainerView.bounds.height))px"
    let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
    contentController.addUserScript(userScript)
    webConfiguration.userContentController = contentController
    self.messageWebView = WKWebView(frame: self.webViewContainerView.bounds, configuration: webConfiguration)
    self.messageWebView.uiDelegate = self
    self.messageWebView.navigationDelegate = self
    self.messageWebView.scrollView.isScrollEnabled = false
    self.webViewContainerView.addSubview(self.messageWebView)
    self.messageWebView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
  }
  
  private func createHtml(embedHtml: String) -> String {
    let html = "<!DOCTYPE html>" +
      "<html>" +
      "<head>" +
      "<meta name=\"viewport\" content=\"width=\(self.webViewContainerView.bounds.width), height=\(self.webViewContainerView.bounds.height), user-scalable=no\">" +
      "<style>" +
      "body {" +
      "margin: 0" +
      "}" +
      ".video-container {" +
      "position:relative;" +
      "padding-bottom:56.25%;" +
      "padding-top:30px;" +
      "height:0;" +
      "overflow:hidden;" +
      "}" +
    ".video-container iframe, .video-container object, .video-container embed {" +
      "position:absolute;" +
      "top:0;" +
      "left:0;" +
      "width:100%;" +
      "height:100%;" +
      "}" +
      "</style>" +
      "</head>" +
      "<body>" +
      "<div class=\"video-container\">" +
      embedHtml +
      "</div>" +
      "</body>" +
    "</html>"
    
    return html
  }
}

// MARK: - Scroll View Delegate Methods

extension MessageModalViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView.isEqual(containerView) else {
      return
    }
    
    if let delegate = transitioningDelegate as? DeckTransitioningDelegate {
      if scrollView.contentOffset.y > 0 {
        scrollView.bounces = true
        delegate.isDismissEnabled = false
      } else {
        if scrollView.isDecelerating {
          view.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
          scrollView.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
        } else {
          scrollView.bounces = false
          delegate.isDismissEnabled = true
        }
      }
    }
  }
}
