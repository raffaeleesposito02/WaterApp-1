//
//  FavouritesSingleton.swift
//  WaterApp
//
//  Created by Raffaele on 18/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import Foundation

class Favourite {
    static var shared = Favourite()
    
    var favouritePlace: [String] = []
    var favouriteMarkersImages: [String] = []
}
