//
//  DiscoveryViewController.swift
//  CastrApp
//
//  Created by Castr on 07/07/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DeckTransition

class DiscoveryViewController: UIViewController, UISearchBarDelegate {
  
  // MARK: - IB Outlets
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var createChatroomButton: UIButton!
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Properties

  lazy var sortBar : SortBar = {
    let bar = SortBar()
    bar.discoveryViewController = self
    return bar
  }()

  var searchResultsController = SearchResultsViewController()
  var searchController = UISearchController()
  var discoveryControllers: [DiscoveryContentViewController] = []
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.definesPresentationContext = true
    self.automaticallyAdjustsScrollViewInsets = false
    self.setupViewControllers()
    self.setupSortBar()
    self.setupCollectionView()
    self.setupSearchController()
    self.navigationItem.titleView = UIImageView.init(image: #imageLiteral(resourceName: "Castr Color"))
    if #available(iOS 11.0, *) {
      self.collectionView.contentInsetAdjustmentBehavior = .never
    } else {
      self.automaticallyAdjustsScrollViewInsets = false
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - UI Setups

  private func setupSortBar() {
    view.addSubview(sortBar)
    view.addConstraintsWithFormat(format: "H:|[v0]|", views: sortBar)
    view.addConstraintsWithFormat(format: "V:|[v0(50)]", views: sortBar)
  }
  
  private func setupCollectionView() {
    if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.scrollDirection = .horizontal
      flowLayout.minimumLineSpacing = 0
    }
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
  }
  
  private func setupViewControllers() {
    let popularsVC = storyboard?.instantiateViewController(withIdentifier: "DiscoveryContentViewControllerId") as! DiscoveryContentViewController
    popularsVC.sorting = .populars
    
    let activesVC = storyboard?.instantiateViewController(withIdentifier: "DiscoveryContentViewControllerId") as! DiscoveryContentViewController
    activesVC.sorting = .actives
    
    let recentsVC = storyboard?.instantiateViewController(withIdentifier: "DiscoveryContentViewControllerId") as! DiscoveryContentViewController
    recentsVC.sorting = .recents
  
    discoveryControllers = [popularsVC, activesVC, recentsVC]
  }
  
  private func setupSearchController() {
    searchResultsController = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! SearchResultsViewController
    searchController = {
      let searchVc = UISearchController(searchResultsController: searchResultsController)
      searchVc.dimsBackgroundDuringPresentation = true
      searchVc.searchResultsUpdater = searchResultsController
      searchController.hidesNavigationBarDuringPresentation = true
      UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Roboto-Bold", size: 15)!], for: .normal)
      UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "ANNULER"
      searchVc.searchBar.delegate = searchResultsController
      searchVc.searchBar.keyboardAppearance = .dark
      searchVc.searchBar.isTranslucent = false
      searchVc.searchBar.barTintColor = UIColor.castrGray
      searchVc.searchBar.textField?.backgroundColor = UIColor.castrLightGray
      searchVc.searchBar.textField?.textColor = UIColor.castrBlue
      searchVc.searchBar.textField?.font = UIFont(name: "Roboto-Regular", size: 17)
      searchVc.searchBar.textField?.attributedPlaceholder = NSAttributedString(string: "Chercher une chatroom", attributes:
        [ NSForegroundColorAttributeName: UIColor.gray,
          NSFontAttributeName : UIFont(name: "Roboto-Regular", size: 17)!
        ])
      searchVc.searchBar.tintColor = UIColor.castrBlue
      return searchVc
    }()
  }
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - Search Action
  
  @IBAction func searchAction(_ sender: Any) {
    self.present(searchController, animated: true, completion: nil)
  }
  
}

// -----------------------------------------------------------------------------------------------

// MARK: - UICollectionView Datasource & Delegate

extension DiscoveryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollToMenuIndex(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.sortBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x/3
    }
  
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
      let index = targetContentOffset.pointee.x / view.frame.width
      let indexPath = IndexPath(item: Int(index), section: 0)
      self.sortBar.sortView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoveryCollectionViewCellId", for: indexPath) as! DiscoveryCollectionViewCell
      display(contentController: self.discoveryControllers[indexPath.row], on: cell)
      return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
  
    func display(contentController content: UIViewController, on view: UIView) {
      self.addChildViewController(content)
      content.view.frame = view.bounds
      view.addSubview(content.view)
      content.didMove(toParentViewController: self)
    }
}

enum DiscoverySorting {
  case populars
  case actives
  case recents
}

