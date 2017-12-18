//
//  MapViewController.swift
//  WaterApp
//
//  Created by Grazia Mazzei on 09/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var popView: UIView!
    
    //WHEN MARKER IS TAPPED
    func mapView(_ mapView:GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        popView.isHidden = false
        
//        performSegue(withIdentifier: "markerTapped", sender: nil)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        popView.isHidden = true
        
    }
    
    // OUTLETS
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    // VARIABLES
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popView.isHidden = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initGoogleMaps()
        
        popView.layer.cornerRadius = 10

    }
    
    func initGoogleMaps() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        
        
        // Creates a marker in the center of the map.
    /*    let marker = GMSMarker()
               marker.position = CLLocationCoordinate2D(latitude:47.383473872101504 , longitude: 6.240234375)
        marker.title = "Castel dell'Ovo"
        marker.snippet = "Australia"
        marker.map = googleMapsView
        marker.icon = #imageLiteral(resourceName: "flag-map-marker") */
        createrMarker(40, 14);
     
    }
    
 

   func createrMarker(_ latitude: Float ,_ longitude: Float) {
        let marker = GMSMarker()
      
        var location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        marker.position = location
    marker.title = "Location.name"
    marker.snippet = "Info window text"
    marker.map = googleMapsView
    }

    
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
 
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.googleMapsView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        filter.country = "uk"
    }
    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapsView.isMyLocationEnabled = true
    }
    
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.googleMapsView.camera = camera
        self.dismiss(animated: true, completion: nil) // dismiss after select place
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    @IBAction func openSearchAddress(_ sender: UIBarButtonItem) {
        let autocompletecontroller = GMSAutocompleteViewController()
        autocompletecontroller.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .city //suitable filter type
        filter.country = "IT"  //appropriate country code
        autocompletecontroller.autocompleteFilter = filter
        self.present(autocompletecontroller, animated: true, completion: nil)
    }
}
