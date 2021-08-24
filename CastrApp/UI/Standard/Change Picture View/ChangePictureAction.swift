//
//  ChangePictureAction.swift
//  CastrApp
//
//  Created by Antoine on 25/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import UIKit

enum ChangePictureAction {

   case setPicture(UIImage)
   case setUploading(Progress)
   case setDone
   case setError(CastrError)
}
