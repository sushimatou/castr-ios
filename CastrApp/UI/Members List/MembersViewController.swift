//
//  MembersViewController.swift
//  CastrApp
//
//  Created by Antoine on 31/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class MembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let sections = ["UTILISATEURS INSCRITS","UTILISATEURS ANONYMES"]
    var chatroomId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MembersPresenter.instance.bind(view: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.darkGray
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MemberCellId") as UITableViewCell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
