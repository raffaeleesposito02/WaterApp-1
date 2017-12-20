//
//  Preference.swift
//  WaterApp
//
//  Created by Luigi Previdente on 12/20/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import Foundation
import UIKit

class Preference {
    
    var analisysData = Array<Array<String>>()
    var ukey: String =  "";
    var city: String = "";
    var locality: String = "";
    var area: String = "";
    var latitude: String = "";
    var longitude: String = "";
    
    init(data: [[String]]) {
        // because the first row if empty
        if(data.count > 1) {
            area = data[1][0];
            city = data[1][1];
            locality = data[1][2];
            
            if((Float(data[1][3]) ?? 0) != 0) {
                latitude = data[1][3];
                longitude = data[1][4];
            }
            else {
                latitude = data[1][4];
                longitude = data[1][5];
            }
            for i in 1...data.count-1 {
                var temp = Array<String>() ;
                // I take the last 3 informations : DATE Enterococchi Escherichia
                for j in data[i].count-3...data[i].count-1 {
                    temp.append(data[i][j]);
                }
                analisysData.append(temp);
            }
       
        }
        else{
            print("There is no value");
        }
    }
    
    func toDictionary()-> [String: String] {
        var dict = [ String : String ]();
        dict["Area"] = area;
        dict["Locality"] = locality;
        dict["City"] = city;
        dict["Latitude"] = latitude;
        dict["Longitude"] = longitude;
        return dict;
    }
    
    func toDictionaryArray() -> [String: [String]] {
        var dict = [String: [String]]();
        
        for i in 0...analisysData.count-1 {
            dict[String(i)] = analisysData [i]
        }
        return dict;
    }
}
