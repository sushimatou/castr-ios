//
//  ToastView.swift
//  CastrApp
//
//  Created by Antoine on 07/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

enum ToastViewState {
  case connection
  case connected
}

class ToastView: UIView {
  
  // MARK: - Properties
  
  @IBOutlet weak var toastView: UIView!
  @IBOutlet weak var toastLabel: UILabel!
  
  static func loadFromXib() -> ToastView?  {
    
    let nib = UINib(nibName: "ToastView", bundle: Bundle.main)
    return nib.instantiate(withOwner: self, options: nil).first as? ToastView
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func show(viewController: UIViewController) {
    
    self.frame = viewController.view.frame
    self.toastView.center = CGPoint(x: self.center.x,
                                    y: self.frame.height + self.toastView.frame.height / 2)
    
    viewController.view.addSubview(self)
    
    toastView.backgroundColor = .castrOrange
    toastLabel.text = "Connexion à Castr en cours..."
    UIView.animate(withDuration: 0.7) {
      self.toastView.center = CGPoint(x: self.center.x,
                                        y: self.center.y -  self.toastView.frame.height / 2 - 2)
    }
  }
  
  func dismiss() {
    toastView.backgroundColor = .castrGreen
    toastLabel.text = "Connecté à Castr"
    UIView.animate(withDuration: 0.7, delay: 2, options: UIViewAnimationOptions(), animations: {
      self.toastView.center = CGPoint(x: self.center.x,
                                      y: self.frame.height + self.toastView.frame.height / 2)
    
    })
    self.removeFromSuperview()
    
  }
    
}

