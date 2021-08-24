//
//  ResultsViewController.swift
//  CastrApp
//
//  Created by Antoine on 25/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultsViewController: UIViewController {
  
  // MARK : - IBOutlets
  
  @IBOutlet weak var queryLabel: UILabel!
  @IBOutlet weak var noResultStackView: UIStackView!
  @IBOutlet weak var resultsTableView: UITableView!
  @IBOutlet weak var waitingView: UIView!
  
  // MARK : - Properties
  
  let autocompleteSubject = PublishSubject<String>()
  let searchSubject = PublishSubject<String>()
  var results: [SearchResultsDto] = []
  
  
  // MARK : - Life Cycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    SearchPresenter.instance.bind(view: self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    SearchPresenter.instance.unbind(view: self)
  }
  
  // MARK : - Render Method
  
  func render(state: SearchResultsViewState) {
    self.waitingView.isHidden = !state.isLoading
    self.noResultStackView.isHidden = state.resultsBySearch.count != 0
    self.results = state.resultsByAutocomplete
    print(self.results)
    resultsTableView.reloadData()
  }
  
}

// MARK : - SearchResultUpdater Object Method

extension SearchResultsViewController : UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    self.autocompleteSubject.onNext(searchController.searchBar.text!)
  }
  
}

// MARK : - UISearchBarDelegate Methods

extension SearchResultsViewController : UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.searchSubject.onNext(searchBar.text!)
  }
  
}

// MARK : - Tableview Datasource & Delegate Methods

extension SearchResultsViewController : UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteCellId") as! SearchResultTableViewCell
    //cell.selectedBackgroundView = .clearColor
    cell.result = results[indexPath.row]
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chatroomVc = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomViewController") as! MessagingViewController
    chatroomVc.context = .chatroom
    chatroomVc.contextId = results[indexPath.row].id
    self.dismiss(animated: true, completion: {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.window?.visibleViewController?.show(chatroomVc, sender: nil)
    })
  }
}
