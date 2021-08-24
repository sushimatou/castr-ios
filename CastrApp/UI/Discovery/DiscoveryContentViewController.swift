//
//  DiscoveryContentViewController.swift
//  CastrApp
//
//  Created by Antoine on 02/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift

class DiscoveryContentViewController: UIViewController {
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - IBOutlets & Properties
  
  @IBOutlet weak var waitingView: UIView!
  @IBOutlet weak var chatroomTableView: UITableView!

  let loadMoreSubject = PublishSubject<Double>()
  var sorting: DiscoverySorting?
  var chatroomList: [ChatroomDTO] = []
  var isLoadingMore: Bool = false
  var isAtBotton: Bool = false
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.chatroomTableView.estimatedRowHeight = 80
    self.chatroomTableView.rowHeight = UITableViewAutomaticDimension
    self.getPresenter().bind(view: self)
    self.waitingView.isHidden = false
    if #available(iOS 11.0, *) {
      self.chatroomTableView.contentInsetAdjustmentBehavior = .never
    } else {
      self.automaticallyAdjustsScrollViewInsets = false
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.chatroomTableView.contentInset = UIEdgeInsetsMake(30, 0, 30, 0)
    self.chatroomTableView.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 30, 0)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.chatroomTableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
  }
  
  func getPresenter() -> DiscoveryPresenter {
    return DiscoveryPresenter()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Render Methods
  
  func render(state: DiscoveryViewState) {
    self.chatroomList = state.chatroomList
    self.chatroomTableView.reloadData()
    self.isLoadingMore = state.isLoadingMore
    self.isAtBotton = state.isAtBottom
    waitingView.isHidden = true
  }
  
  func errorPrint(error: CastrError){
    let alertView = AlertView.loadFromXib()
    alertView?.create(title: "Erreur", text: "\(error)", withCancelButton: false)
    alertView?.show(viewController: self)
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "chatroomSegue" {
      let chatroomViewController = segue.destination as! MessagingViewController
      if let selectedIndexPath = chatroomTableView.indexPathForSelectedRow {
        let id = chatroomList[selectedIndexPath.row].id
        let name = chatroomList[selectedIndexPath.row].name
        chatroomViewController.context = .chatroom
        chatroomViewController.contextId = id
        chatroomViewController.chatroomName = name
        chatroomTableView.deselectRow(at: selectedIndexPath, animated: true)
      }
    }
  }
}

// -------------------------------------------------------------------------------------------------

// MARK : TableView Datasource & Delegate Methods

extension DiscoveryContentViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    let chatroom = chatroomList[row]
    let chatroomCell = tableView.dequeueReusableCell(withIdentifier: "ChatroomCell", for: indexPath) as! DiscoveryTableViewCell
    chatroomCell.setChatroom(chatroom: chatroom)
    return chatroomCell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatroomList.count
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row == chatroomList.count - 1 && !self.isAtBotton {
      let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
      spinner.startAnimating()
      spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
      tableView.tableFooterView = spinner
      tableView.tableFooterView?.isHidden = false
      if !self.isLoadingMore {
        self.loadMoreSubject.onNext(chatroomList[indexPath.row].rank)
      }
    }
  }
}
