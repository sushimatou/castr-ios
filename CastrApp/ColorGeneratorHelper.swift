//
//  ColorGeneratorHelper.swift
//  CastrApp
//
//  Created by Castr on 30/06/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

class ColorGeneratorHelper {
    
    static let colors = ["#EC297B", "#CE1BCE", "#37B34A", "#46CECE", "#DB8700", "#31AFCA", "#F2460A", "#2C7BD8", "#Ef2E2E", "#78AF00", "#2D292A"]
    
    static func getRandomColor() -> Int {
        return Int(arc4random_uniform(10))
    }
    
    static func getColorwithId(id: Int) -> String {
        return self.colors[id]
    }
    
}
