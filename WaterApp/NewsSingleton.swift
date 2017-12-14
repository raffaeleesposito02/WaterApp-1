//
//  NewsSingleton.swift
//  WaterApp
//
//  Created by Raffaele on 12/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import Foundation
import UIKit

class News {
    static var article = News()
    
    var newsTit: String = ""
    var newsCnt: String = ""
    var newsImgName: String = ""
}
