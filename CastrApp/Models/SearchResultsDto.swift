//
//  SearchResultsDTO.swift
//  CastrApp
//
//  Created by Antoine on 27/09/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct SearchResultsDto {

    var id: String
    var color: Int
    var score: Double
    var name: String
    var description: String?
    var picture: String?
    
    init(json: JSON) {
        self.id = json["_id"].stringValue
        self.score = json["_score"].doubleValue
        self.color = json["_source"]["color"].intValue
        self.name = json["_source"]["name"].stringValue
        self.description = json["_source"]["description"].string
        self.picture = json["_source"]["picture"].string
    }

}

