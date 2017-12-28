//
//  Analysis.swift
//  GoogleToolboxForMac
//
//  Created by Alessio Antonisio on 27/12/2017.
//

import Foundation
import MapKit

class AnalysisPoint: NSObject, MKAnnotation {

    let coordinate: CLLocationCoordinate2D
    let vEnterococchi: Int;
    let vEscherichia: Int;
    
    init( _ coordinate: CLLocationCoordinate2D, _ vEnterococchi: Int, _ vEscherichia: Int) {
        self.coordinate = coordinate;
        self.vEnterococchi = vEnterococchi;
        self.vEscherichia = vEscherichia;
        super.init()
    }
}
