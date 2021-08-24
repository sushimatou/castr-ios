//
//  StyleHelper.swift
//  CastrApp
//
//  Created by Castr on 20/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Hex

extension String {
    
    func capitalizeFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        
        self = self.capitalizeFirstLetter()
        
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension UILabel {
    
    func toBold() {
        
        self.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.textColor = UIColor.white
        
    }
    
}

extension UITextView: UITextViewDelegate {
    
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }

    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    

    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }

    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.contentInset = UIEdgeInsetsMake(3,10,0,0);
        self.delegate = self
    }
}

extension UITextField {
    
    func callbackWithState(state: FieldState){
        
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        
        switch state {
        
        case .valid:
            self.layer.borderColor = UIColor.castrGreen.cgColor
        case .error(let error):
            self.layer.borderColor = UIColor.castrRed.cgColor
            self.attributedPlaceholder = NSAttributedString(string:error,
                                                                     attributes: [NSForegroundColorAttributeName: UIColor.castrRed])
        case .loading:
            self.layer.borderColor = UIColor.castrBlue.cgColor
        case .pristine:
            self.layer.borderWidth = 0
        }
    }
}

extension UIColor {
    
    static var castrOrange = UIColor(hex: "#E5440C")
    static var castrRed = UIColor(hex: "#B50F32")
    static var castrGreen = UIColor(hex: "#37B34A")
    static var castrYellow = UIColor(hex: "#EDDF2E")
    static var castrBlue = UIColor(hex: "#3FA5EF")
    static var castrPink = UIColor(hex: "#EC297B")
    static var castrPurple = UIColor(hex: "#BA5BE1")
    static var castrBrightRed = UIColor(hex: "#ED3136")
    static var castrGray = UIColor(hex: "#231F20")
    static var castrLightGray = UIColor(hex: "2D292A")
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension UISearchBar {
    var textField: UITextField? {
        return subviews.first?.subviews.first(where: { $0.isKind(of: UITextField.self) }) as? UITextField
    }
}

extension UICollectionView {
    func deselectAllItems(animated: Bool = false) {
        for indexPath in self.indexPathsForSelectedItems ?? [] {
            self.deselectItem(at: indexPath, animated: animated)
        }
    }
}

public extension UIImage {
    public func resize(height: CGFloat) -> UIImage? {
        let scale = height / self.size.height
        let width = self.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(in: CGRect(x:0, y:0, width:width, height:height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
}



