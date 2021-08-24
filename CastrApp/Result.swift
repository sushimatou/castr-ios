//
//  MessageResult.swift
//  CastrApp
//
//  Created by Antoine on 10/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation

public enum Result<Value> {
    case success(Value)
    case failed(error: CastrError)
}
