//
//  ChatroomInfosViewController.swift
//  CastrApp
//
//  Created by Antoine on 27/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class ChatroomInfosViewController: UIViewController {
  
  // MARK: - IB Outlets
  
  @IBOutlet weak var quitChatroomButton: UIButton!
  @IBOutlet weak var seeMembersButton: UIButton!
  @IBOutlet weak var favoriteButton: UIButton!
  @IBOutlet weak var adminTableView: UITableView!
  @IBOutlet weak var picView: UIImageView!
  @IBOutlet weak var chatroomNameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var messagesCountLabel: UILabel!
  @IBOutlet weak var lovesCountLabel: UILabel!
  @IBOutlet weak var membersCountLabel: UILabel!
  @IBOutlet weak var newMsgNotificationSwitch: UISwitch!
  @IBOutlet weak var InactivityNotificationSwitch: UISwitch!
  
  // MARK: - Properties
  var infos: ChatroomDTO?
  var admins = [UserDTO]()
  var modos = [UserDTO]()
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad(){
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    ChatroomInfosPresenter.instance.bind(view: self)
    self.reloadUI()
  }
  
  func render(state: ChatroomInfosViewState){
    print("ChatroomInfos - VC - render")
    self.infos = state.infos
    self.admins = state.admins
    print(admins.count)
    self.adminTableView.reloadData()
  }
  
  func reloadUI(){
    let color = UIColor(hex: ColorGeneratorHelper
      .getColorwithId(id: self.infos!.color))
    self.picView.backgroundColor = color
    self.chatroomNameLabel.text = self.infos?.name
    self.descriptionLabel.text = self.infos?.description ?? "Pas de description"
    self.messagesCountLabel.text = String(describing: self.infos?.messagesCount)
    self.lovesCountLabel.text = String(describing: self.infos?.loveCount)
    self.membersCountLabel.text = String(describing: self.infos?.membersCount)
    self.favoriteButton.isHidden = !self.infos!.isFavorite
  }

}

extension ChatroomInfosViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "administrateurs".uppercased()
    case 1:
      return "modérateurs".uppercased()
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return self.admins.count
    case 1:
      return self.modos.count
    default:
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatroomAdminTableViewCellId") as! ChatroomAdminTableViewCell
    switch indexPath.section {
    case 0:
      cell.user = self.admins[indexPath.row]
    case 1:
      cell.user = self.modos[indexPath.row]
    default:
      break //NOOP
    }
    return cell
  }
}
