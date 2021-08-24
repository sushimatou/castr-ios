//
//  FeedViewController.swift
//  CastrApp
//
//  Created by Antoine on 02/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift

class FeedViewController: UIViewController {
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - IBOutlets & Properties
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  lazy var categoryBar : CategoryBar = {
    let bar = CategoryBar()
    bar.feedViewController = self
    return bar
  }()
  
  var feedControllers: [FeedContentViewController] = []
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    self.navigationItem.titleView = UIImageView.init(image: #imageLiteral(resourceName: "Messages Color"))
    self.setupSortBar()
    self.setupCollectionView()
    self.setupFeedControllers()
  } 
  
  // -----------------------------------------------------------------------------------------------
  
  // MARK: - UI Setups
  
  private func setupSortBar() {
    view.addSubview(categoryBar)
    view.addConstraintsWithFormat(format: "H:|[v0]|", views: categoryBar)
    view.addConstraintsWithFormat(format: "V:|[v0(50)]", views: categoryBar)
  }
  
  private func setupCollectionView() {
    if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.scrollDirection = .horizontal
      flowLayout.minimumLineSpacing = 0
    }
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
  }
  
  private func setupFeedControllers() {
    let notificationVC = storyboard?.instantiateViewController(withIdentifier: "FeedContentViewControllerId") as! FeedContentViewController
    notificationVC.sorting = .notifications
    
    let favoritesVC = storyboard?.instantiateViewController(withIdentifier: "FeedContentViewControllerId") as! FeedContentViewController
    favoritesVC.sorting = .favorites
    
    let messagesVC = storyboard?.instantiateViewController(withIdentifier: "FeedContentViewControllerId") as! FeedContentViewController
    messagesVC.sorting = .chats
    feedControllers = [notificationVC, favoritesVC, messagesVC]
  }
  
}

// -----------------------------------------------------------------------------------------------

// MARK: - UICollectionView Datasource & Delegate

extension FeedViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func scrollToMenuIndex(index: Int) {
    let indexPath = IndexPath(item: index, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.categoryBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x/3
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    for indexPath in categoryBar.categoryView.indexPathsForVisibleItems {
      categoryBar.collectionView(self.categoryBar.categoryView, didDeselectItemAt: indexPath)
    }
    let index = targetContentOffset.pointee.x / view.frame.width
    let indexPath = IndexPath(item: Int(index), section: 0)
    self.categoryBar.collectionView(self.categoryBar.categoryView, didSelectItemAt: indexPath)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discoveryCollectionViewCellId", for: indexPath) as! DiscoveryCollectionViewCell
    display(contentController: self.feedControllers[indexPath.row], on: cell)
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

enum FeedSorting: String {
  case notifications = "notifications"
  case favorites = "favorites"
  case chats = "chats"
}
