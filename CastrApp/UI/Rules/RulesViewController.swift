//
//  RulesViewController.swift
//  CastrApp
//
//  Created by Antoine on 09/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift
import RxKeyboard

class RulesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
  
  // MARK: - IB Outlets
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var rythmTextField: UITextField!
  @IBOutlet weak var accessTextField: UITextField!
  
  // MARK: - Properties
  
  let accessRules = ["Ouverte au public", "Sur invitation"]
  let rythmRules = ["Libre", "Toutes les 10 secondes", "Toutes les 30 secondes", "Toutes les minutes"]
  let picker = UIPickerView()
  let toolbar = UIToolbar()
  private let disposeBag = DisposeBag()
  let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
  
  // MARK: - LifeCycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    obsKeyboard()
    toolbar.setItems([flexibleSpace,doneButton], animated: false)
    toolbar.sizeToFit()
    toolbar.tintColor = UIColor.white
    toolbar.barTintColor = UIColor.darkGray
    picker.delegate = self
    picker.dataSource = self
    accessTextField.inputView = picker
    accessTextField.inputAccessoryView = toolbar
    accessTextField.tintColor = UIColor.clear
  }
  
  func doneClicked(){
    
  }
  
  // MARK: - Picker Datasource & Delegate Methods
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return accessRules.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return accessRules[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    accessTextField.text = accessRules[row]
  }
  
  // MARK: - Keyboard Obs
  
  func obsKeyboard() {
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { keyboardVisibleHeight in
        self.scrollView.contentInset.bottom = keyboardVisibleHeight
        self.scrollView.scrollIndicatorInsets.bottom = keyboardVisibleHeight
      })
      .disposed(by: disposeBag)
  }
}
