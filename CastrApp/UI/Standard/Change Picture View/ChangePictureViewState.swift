//
//  ChangePictureViewState.swift
//  CastrApp
//
//  Created by Antoine on 25/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

enum ChangePictureViewState {
    case empty(media: UIImage?)
    case error(_: CastrError)
    case uploading(progress: Progress)
    case uploaded
}
