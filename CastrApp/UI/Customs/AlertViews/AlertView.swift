//
//  CustomAlertView.swift
//  CastrApp
//
//  Created by Antoine on 29/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

class AlertView : UIView {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var okButton: RoundedButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var cancelButton: RoundedButton!
    
    // MARK: - Properties
    
    var okCompletionHandler : (() -> Swift.Void)?
    
    static func loadFromXib() -> AlertView?  {
        let nib = UINib(nibName: "AlertView", bundle: Bundle.main)
        return nib.instantiate(withOwner: self, options: nil).first as? AlertView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func create(title: String, text: String?, icon: UIImage? = nil, okCompletionHandler: (() -> Swift.Void)? = nil, withCancelButton: Bool) {
        self.titleLabel.text = title.uppercased()
        if let text = text {
            self.textLabel.text = text
        }
        else {
            self.textLabel.isHidden = true
        }
        self.cancelButton.isHidden = !withCancelButton
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height/2)
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
