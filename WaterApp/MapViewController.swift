//
//  MapViewController.swift
//  WaterApp
//
//  Created by Grazia Mazzei on 09/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var userPosition: CLLocationCoordinate2D!
    var managerPosition: CLLocationManager!

    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController (searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.managerPosition = CLLocationManager()
        managerPosition.delegate = self
        managerPosition.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        managerPosition.requestWhenInUseAuthorization()
        managerPosition.startUpdatingLocation()
   }
    
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        self.userPosition = userLocation.coordinate
        
        print("Position updated - lat: \(userLocation.coordinate.latitude) long: \(userLocation.coordinate.longitude)")
    
/*        let start = DispatchTime.now()
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegion(center: userPosition, span: span)
        
        mapView.setRegion(region, animated: true)
        
        sleep(20)
        
        let end = DispatchTime.now()
 */
        let actualSpan = mapView.region.span
        let actualRegion = mapView.region.center
 
        let region = MKCoordinateRegion(center: actualRegion, span: actualSpan)

        mapView.setRegion(region, animated: true)
    }
    
    
    
    @IBAction func refLocation(_ sender: Any) {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
    }
    
    @IBAction func findPosition(_ sender: UIButton) {
       dismiss(animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        //Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //hide search bar
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //create search request
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil
            {
                print("ERROR")
            }
            else
            {
                //remove annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                //Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //create annotations
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                //zooming annotations
                self.managerPosition.startUpdatingLocation()
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D( latitude: latitude!, longitude: longitude!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.mapView.setRegion(region, animated: true)
                
            }
        }
     
    }
}
