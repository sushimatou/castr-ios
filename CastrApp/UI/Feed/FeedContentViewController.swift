//
//  FeedContentViewController.swift
//  CastrApp
//
//  Created by Antoine on 03/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class FeedContentViewController: UIViewController {
  
  // MARK: - IBOutlets & Properties
  
  @IBOutlet weak var feedTableView: UITableView!
  @IBOutlet weak var waitingView: UIView!
  @IBOutlet weak var emptyStateView: UIView!
  
  let loadMoreSubject = PublishSubject<Int>()
  let deleteIntentSubject = PublishSubject<FeedElement>()
  var sorting: FeedSorting?
  var feedContentList: [FeedElement] = []
  var isLoadingMore: Bool = false
  var isAtBottom: Bool = false
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    self.feedTableView.contentInset = UIEdgeInsetsMake(30, 0, 30, 0)
    self.feedTableView.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 30, 0)
    self.feedTableView.estimatedRowHeight = 100
    self.feedTableView.rowHeight = UITableViewAutomaticDimension
    self.waitingView.isHidden = false
    FeedPresenter().bind(view: self)
  }
    
  // MARK: - Actions
    
  @IBAction func deleteAction(_ sender: UIButton) {
    sender.isEnabled = false
    let buttonPosition = sender.convert(CGPoint.zero, to: self.feedTableView)
    let indexPath = self.feedTableView.indexPathForRow(at: buttonPosition)
    let feedElement = feedContentList[indexPath!.row]
    self.deleteIntentSubject.onNext(feedElement)
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Render
  
  func render(state: FeedState) {
    self.waitingView.isHidden = !state.isLoading
    self.emptyStateView.isHidden = !state.isEmpty
    self.feedContentList = state.feedElements
    self.feedTableView.reloadData()
    self.isAtBottom = state.isAtBottom
    self.isLoadingMore = state.isLoadingMore
  }

}

// -------------------------------------------------------------------------------------------------

// MARK : - TableView Datasource & Delegate Methods

extension FeedContentViewController : UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.feedContentList.count
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == feedContentList.count - 1 && !self.isAtBottom {
      if !self.isLoadingMore {
        
        if case FeedElement.chat(let chat) = self.feedContentList.last! {
            self.loadMoreSubject.onNext(chat.lastUpdate)
        }
        else if case FeedElement.favorite(let favorite) = self.feedContentList.last! {
            self.loadMoreSubject.onNext(favorite.lastUpdate)
        }
        else if case FeedElement.notification(let notification) = self.feedContentList.last! {
          self.loadMoreSubject.onNext(notification.lastUpdate)
        }
      }
      let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
      spinner.startAnimating()
      spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
      tableView.tableFooterView = spinner
      tableView.tableFooterView?.isHidden = false
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let feedElement = self.feedContentList[indexPath.row]
      
      switch feedElement {
        
      case .notification(let notification):
        
        // Notifications
        
        switch notification.type {
          
        case .invite:
          
          let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCellId") as! FeedInviteTableViewCell
          cell.notification = notification
          return cell
          
        case .warning:
          
          let cell = tableView.dequeueReusableCell(withIdentifier: "WarningCellId") as! FeedWarningTableViewCell
          cell.notification = notification
          return cell
          
        case .ban:
          
          let cell = tableView.dequeueReusableCell(withIdentifier: "BanCellId") as! FeedBanTableViewCell
          cell.notification = notification
          return cell
          
        case .love:
          let cell = tableView.dequeueReusableCell(withIdentifier: "LoveCellId") as! FeedLoveTableViewCell
          cell.notification = notification
          return cell
          
        case .quote:
          let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCellId") as! FeedQuoteTableViewCell
          cell.notification = notification
          return cell
          
        case .roleUpdate:
          let cell = tableView.dequeueReusableCell(withIdentifier: "RoleCellId") as! FeedRoleTableViewCell
          return cell
          
        }
        
      // Chats & Favorites
        
      case .chat(let chat):
        let cell =  tableView.dequeueReusableCell(withIdentifier: "MessageCellId") as! FeedChatTableViewCell
        cell.chat = chat
        return cell
        
      case .favorite(let favorite):
        let cell =  tableView.dequeueReusableCell(withIdentifier: "FavoriteCellId") as! FeedFavoriteTableViewCell
        cell.favorite = favorite
        return cell
        
      }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let selectedElement = self.feedContentList[indexPath.row]
    
    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomViewController") as! MessagingViewController
    
    switch selectedElement {
    case .notification(let notification):
      vc.context = .chatroom
      vc.contextId = notification.chatroom.id
    case .chat(let chat):
      vc.context = .chat
      vc.contextId = chat.id
    case .favorite(let favorite):
      vc.context = .chatroom
      vc.contextId = favorite.id
    }
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
}


