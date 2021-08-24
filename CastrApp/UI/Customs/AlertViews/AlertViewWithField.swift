//
//  LogInAlertView.swift
//  CastrApp
//
//  Created by Antoine on 02/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

class AlertViewWithField : UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var textField: CustomTextField!
    
    // MARK: - Properties
    
    var okCompletionHandler : (() -> Swift.Void)?
    
    static func loadFromXib() -> AlertViewWithField?  {
        let nib = UINib(nibName: "AlertViewWithField", bundle: Bundle.main)
        return nib.instantiate(withOwner: self, options: nil).first as? AlertViewWithField
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func create(title: String, placeholder: String?, okCompletionHandler: (() -> Swift.Void)? = nil) {
        self.titleLabel.text = title.uppercased()
        self.textField.placeholder = placeholder
        self.textField.keyboardType = .default
        self.okCompletionHandler = okCompletionHandler
    }
    
    func show(viewController: UIViewController, completion: (() -> Swift.Void)? = nil) {

        self.dialogView.center = CGPoint(x: self.center.x,
                                         y: self.frame.height + self.dialogView.frame.height/2)
        self.alpha = 0.0
        
        dialogView.layer.shadowColor = UIColor.black.cgColor
        dialogView.layer.shadowOpacity = 0.3
        dialogView.layer.shadowRadius = 5
        dialogView.layer.cornerRadius = 5
        
        let window = UIApplication.shared.keyWindow!
        self.frame = window.frame
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 10,
                       options: UIViewAnimationOptions(rawValue: 0),
                       animations: {
                        self.dialogView.center  = self.center
        }, completion: nil)
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 10,
                       options: UIViewAnimationOptions(rawValue: 0),
                       animations: {
            self.dialogView.center = CGPoint(x: self.center.x,
                                             y: self.frame.height + self.dialogView.frame.height/2)
            self.alpha = 0
        }, completion: { (completed) in
            self.removeFromSuperview()
        })
    }
    
    @IBAction func okAction(_ sender: Any) {
        if okCompletionHandler != nil {
            self.okCompletionHandler!()
        }
        dismiss()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss()
    }
    
}
