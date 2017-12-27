//
//  Artwork.swift
//  GoogleToolboxForMac
//
//  Created by Alessio Antonisio on 27/12/2017.
//

import Foundation
import MapKit

class Artwork: NSObject, MKAnnotation {

    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
