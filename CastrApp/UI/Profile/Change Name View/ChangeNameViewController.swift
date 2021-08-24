//
//  ChangeNameViewController.swift
//  CastrApp
//
//  Created by Antoine on 24/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import RxSwift

class ChangeNameViewController: UIViewController {
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - IBOutlets
    
    @IBOutlet weak var changeNameTextField: CustomTextField!
    @IBOutlet weak var changeNameButton: RoundedButton!
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - Properties
    
    var actualName: String!
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeNameTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.changeNameTextField.text = actualName
        self.changeNameButton.isEnabled = false
        ChangeNamePresenter.instance.bind(view: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ChangeNamePresenter.instance.unbind()
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - Intents
    
    func nameEditIntent() -> Observable<String> {
        return changeNameTextField
            .rx
            .text
            .orEmpty
            .asObservable()
    }
    
    func changeNameIntent() -> Observable<String> {
        return changeNameButton
            .rx
            .tap
            .map { _ in
                return self.changeNameTextField.text!
            }
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - Render Method
    
    func render(state: ChangeNameViewState) {
        
        switch state {
            
        case .empty:
            break
            
        case .editing(let nameFieldState):
            self.changeNameTextField.callbackWithState(state: nameFieldState)
            
            if case FieldState.valid = nameFieldState {
                self.changeNameButton.isEnabled = true
            }
            else {
                self.changeNameButton.isEnabled = false
            }
            
        case .changeNameDone:
            self.returnToProfile()
            
        case .loading:
            break
        case .error(_):
            break
            
        }
        
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK : - Navigation
    
    func returnToProfile(){
        self.navigationController?.popViewController(animated: true)
    }

}
