//
//  ApiError.swift
//  CastrApp
//
//  Created by Antoine on 12/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

public enum ApiError : Int,  Error {

    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case backEndError = 500
    case castrUnavailable = 503
    case undefined
    
}
