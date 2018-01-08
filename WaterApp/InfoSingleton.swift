//
//  infoSingleton.swift
//  WaterApp
//
//  Created by Raffaele on 08/01/18.
//  Copyright © 2018 Raffaele. All rights reserved.
//

import Foundation
import UIKit


class Information {
    static var shared = Information()
    
    var infoTitle: String = ""
    var infoContent: String = ""
}

