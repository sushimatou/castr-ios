//
//  CategoryBar.swift
//  CastrApp
//
//  Created by Antoine on 22/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class SortBar: UIView {

    lazy var sortView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let horizontalBarView = UIView()
    let menuCategoryLabels = ["POPULAIRES","ACTIVES","RÉCENTES"]
    
    var discoveryViewController: DiscoveryViewController?
    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let selectedPath = IndexPath(row: 0, section: 0)
        sortView.register(SortCell.self, forCellWithReuseIdentifier: "sortCell")
        addSubview(sortView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: sortView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: sortView)
        sortView.selectItem(at: selectedPath, animated: false, scrollPosition: [])
        setupHorizontalBar()
    }
    
    func setupHorizontalBar() {
        
        horizontalBarView.backgroundColor = UIColor.castrBlue
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

extension SortBar : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sortCell", for: indexPath) as! SortCell
        cell.label.text = menuCategoryLabels[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        discoveryViewController?.scrollToMenuIndex(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

class SortCell : UICollectionViewCell {
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Roboto-Bold", size: 15)
        label.textColor = UIColor.darkGray
        return label
    }()
    
    override var isHighlighted: Bool {
        didSet {
            label.textColor = isHighlighted ? UIColor.white : nil
        }
    }
    
    override var isSelected: Bool {

        didSet {
            label.textColor = isSelected ? UIColor.white : UIColor.darkGray
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addConstraintsWithFormat(format: "V:[v0(28)]", views: label)
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
