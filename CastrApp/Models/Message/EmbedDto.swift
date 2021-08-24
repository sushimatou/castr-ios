//
//  EmbedDto.swift
//  CastrApp
//
//  Created by Antoine on 10/11/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import SwiftyJSON

struct EmbedDto {
    
    var authorName: String?
    var authorUrl: String?
    
    var contentHtml: String?
    var description: String?
    var domain: String?
    var favicon: String?
    
    var providerName: String?
    var providerUrl: String?
    
    var thumbnailUrl: String?
    var title: String?
    var uri: String?
    
    init(json: JSON) {
        self.authorName = json["author"]["name"].string
        self.authorUrl = json["author"]["url"].string
        self.contentHtml = json["content"]["html"].string
        self.description = json["description"].string
        self.domain = json["domain"].string
        self.favicon = json["favicon"].string
        self.providerName = json["provider"]["name"].string
        self.providerUrl = json["provider"]["url"].string
        self.thumbnailUrl = json["thumbnail"]["url"].string
        self.title = json["title"].string
        self.uri = json["uri"].string
    }
    
    
    
}
