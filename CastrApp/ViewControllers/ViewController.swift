//
//  ViewController.swift
//  CastrApp
//
//  Created by Castr on 19/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference(withPath: "/app/info/minVersionCode").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? Int
            print("\(String(describing: value))")
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

