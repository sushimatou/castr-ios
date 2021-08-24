//
//  customNavigationController.swift
//  CastrApp
//
//  Created by Antoine on 01/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.navigationBar.layer.shadowRadius = 5.0
        self.navigationBar.layer.shadowOpacity = 0.2
        self.navigationBar.layer.masksToBounds = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
