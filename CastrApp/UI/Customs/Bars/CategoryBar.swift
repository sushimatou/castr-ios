//
//  CategoryBar.swift
//  CastrApp
//
//  Created by Antoine on 22/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class CategoryBar: UIView {
  
  lazy var categoryView : UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = UIColor.clear
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()
  
  let horizontalBarView = UIView()
  let menuStokeIcons = [#imageLiteral(resourceName: "Recent Icon"),#imageLiteral(resourceName: "Favorite Icon Stoke"),#imageLiteral(resourceName: "Messages Stoke Icon")]
  let menuPlainIcons = [#imageLiteral(resourceName: "Feed Icon"),#imageLiteral(resourceName: "Favorite Icon"),#imageLiteral(resourceName: "Messages Icon")]
  
  var feedViewController: FeedViewController?
  var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    let selectedPath = IndexPath(row: 0, section: 0)
    categoryView.register(CategoryCell.self, forCellWithReuseIdentifier: "categoryCell")
    addSubview(categoryView)
    addConstraintsWithFormat(format: "H:|[v0]|", views: categoryView)
    addConstraintsWithFormat(format: "V:|[v0]|", views: categoryView)
    categoryView.selectItem(at: selectedPath, animated: false, scrollPosition: [])
    setupHorizontalBar()
  }
  
  func setupHorizontalBar() {
    horizontalBarView.backgroundColor = UIColor.castrPurple
    horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(horizontalBarView)
    horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
    horizontalBarLeftAnchorConstraint?.isActive = true
    
    horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3).isActive = true
    horizontalBarView.heightAnchor.constraint(equalToConstant: 3).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK : - Collection View Delegate Methods

extension CategoryBar : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell
    cell.imageView.image = menuStokeIcons[indexPath.row]
    switch indexPath.row {
    case 0:
      cell.imageView.tintColor = .castrPurple
    case 1:
      cell.imageView.tintColor = .castrYellow
    case 2:
      cell.imageView.tintColor = .castrBlue
    default:
      break
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
    cell.imageView.image = menuPlainIcons[indexPath.row]
    feedViewController?.scrollToMenuIndex(index: indexPath.item)
    switch indexPath.row {
    case 0:
      horizontalBarView.backgroundColor = UIColor.castrPurple
      cell.imageView.tintColor = .castrPurple
    case 1:
      horizontalBarView.backgroundColor = UIColor.castrYellow
      cell.imageView.tintColor = .castrYellow
    case 2:
      horizontalBarView.backgroundColor = UIColor.castrBlue
      cell.imageView.tintColor = .castrBlue
    default:
      break
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CategoryCell
    switch indexPath.row {
    case 0:
      cell.imageView.tintColor = .castrPurple
    case 1:
      cell.imageView.tintColor = .castrYellow
    case 2:
      cell.imageView.tintColor = .castrBlue
    default:
      break
    }
    cell.imageView.image = menuStokeIcons[indexPath.row]
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: frame.width / 3, height: frame.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}

class CategoryCell : UICollectionViewCell {
  
  var imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(imageView)
    addConstraintsWithFormat(format: "H:[v0(28)]", views: imageView)
    addConstraintsWithFormat(format: "V:[v0(28)]", views: imageView)
    addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
