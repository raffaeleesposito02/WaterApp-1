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
//             Problema salvataggio Preferenze: \(newFavorite.area!) in memoria
            print("  Stampo l'errore: \n \(errore) \n")
        }
        
    }
    
    func loadAllFavorites() -> [Favorite] {
//      Recupero tutti i libri dal context 
        var array = [Favorite]()
        
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest();
        do {
            array = try self.context.fetch(fetchRequest)
            
            guard array.count > 0 else {
//               Non ci sono elementi da leggere
                return []
            }
            
        } catch let errore {
//           Problema esecuzione FetchRequest
            print("  Stampo l'errore: \n \(errore) \n")

        }
        return array;
    }
    
    func loadFavorite(latitude: Float, longitude: Float) -> Favorite? {
        let request: NSFetchRequest<Favorite> = NSFetchRequest(entityName: "Favorite")
        request.returnsObjectsAsFaults = false
        
        let predicate = NSPredicate(format: "latitude = %@ && longitude = %@", argumentArray: [latitude, longitude])
        request.predicate = predicate
        
        if let favorites = self.loadFavoritesFromFetchRequest(request: request) {
            return favorites[0]
        }
        return nil;
    }
    
    private func loadFavoritesFromFetchRequest(request: NSFetchRequest<Favorite>) -> [Favorite]? {
        
        do {
           let array = try self.context.fetch(request);
            
            guard array.count > 0 else {
//              Non ci sono elementi da leggere fetch Request
                return nil;
            }
            return array;
            
        } catch let errore {
//          Problema esecuzione FetchRequest ;
            print("  Stampo l'errore: \n \(errore) \n");
        }
        return nil;
    }

    func deleteFavorite (latitude: Float, longitude: Float){
        if let favorite = loadFavorite(latitude: latitude, longitude: longitude) {
            self.context.delete(favorite);
        }
        
        do {
            try self.context.save()
        } catch let errore {
//          Problema il salvataggio dopo eliminazione
            print("  Stampo l'errore: \n \(errore) \n")
        }
    }
}
