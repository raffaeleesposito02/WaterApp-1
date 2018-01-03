//
//  CoreDataController.swift
//  WaterApp
//
//  Created by Luigi Previdente on 1/3/18.
//  Copyright © 2018 Raffaele. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// I create a controller for CoreData
class CoreDataController {
    //Make the class a singleton
    static let shared = CoreDataController();
    private var context: NSManagedObjectContext;
    
    private init() {
        var appDelegate = UIApplication.shared.delegate as! AppDelegate;
        self.context = appDelegate.persistentContainer.viewContext;
    }
    
    func addFavorite (area: String, locality: String, latitude: Float, longitude: Float, enterococci: Int16, escherichia: Int16) {
        let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: self.context);
        
        let newFavorite = Favorite(entity: entity!, insertInto: self.context)
        newFavorite.area = area;
        newFavorite.locality = locality;
        newFavorite.enterococci = enterococci;
        newFavorite.escherichia = escherichia;
        newFavorite.latitude = latitude;
        newFavorite.longitude = longitude;
        
        do {
            try self.context.save()
        } catch let errore {
            print("[CDC] Problema salvataggio Preferenze: \(newFavorite.area!) in memoria")
            print("  Stampo l'errore: \n \(errore) \n")
        }
        
        print("[CDC] Preference \(newFavorite.area!) salvato in memoria correttamente")
    }
    
    func loadAllFavorites() -> [Favorite] {
        print("[CDC] Recupero tutti i libri dal context ")
        
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        
        do {
            let array = try self.context.fetch(fetchRequest)
            
            guard array.count > 0 else {
                print("[CDC] Non ci sono elementi da leggere ");
                return []
            }
            
            return array;
            
        } catch let errore {
            print("[CDC] Problema esecuzione FetchRequest")
            print("  Stampo l'errore: \n \(errore) \n")
            return[];
        }
    }
}
