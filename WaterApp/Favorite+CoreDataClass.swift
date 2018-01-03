//
//  Favorite+CoreDataClass.swift
//  WaterApp
//
//  Created by Luigi Previdente on 1/3/18.
//  Copyright © 2018 Raffaele. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Favorite)
public class Favorite: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
}
