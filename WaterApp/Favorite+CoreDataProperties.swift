//
//  Favorite+CoreDataProperties.swift
//  WaterApp
//
//  Created by Luigi Previdente on 1/3/18.
//  Copyright © 2018 Raffaele. All rights reserved.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var area: String?
    @NSManaged public var enterococci: Int16
    @NSManaged public var escherichia: Int16
    @NSManaged public var latitude: Float
    @NSManaged public var locality: String?
    @NSManaged public var longitude: Float

}
