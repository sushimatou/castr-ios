//
//  RandomHelper.swift
//  CastrApp
//
//  Created by Castr on 30/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

extension Array {
    
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
}
