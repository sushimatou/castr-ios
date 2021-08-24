//
//  waitingViewController.swift
//  CastrApp
//
//  Created by Antoine on 01/08/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class WaitingViewController: UIViewController {
    
    @IBOutlet weak var gifView: UIImageView!
    
    let Loading1 = UIImage.gif(name: "Loading1.gif")
    let Loading2 = UIImage.gif(name: "Loading2.gif")
    let Loading3 = UIImage.gif(name: "Loading3")
    let Loading4 = UIImage.gif(name: "Loading4")
    let Loading5 = UIImage.gif(name: "Loading5")
    let Loading6 = UIImage.gif(name: "Loading6")
    
    let loadingGifs = ["Loading1",
                       "Loading2",
                       "Loading3",
                       "Loading4",
                       "Loading5",
                       "Loading6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gifView.loadGif(name: loadingGifs.randomItem())
    }
}
