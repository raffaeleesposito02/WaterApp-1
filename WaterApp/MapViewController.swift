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
import FirebaseStorage

class MapViewController: UIViewController, CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    var storageRef: StorageReference?;
    
    func mapView(_ mapView:GMSMapView, didTap marker: GMSMarker) -> Bool {
        performSegue(withIdentifier: "markerTapped", sender: nil)
        return false
    }
    
    // OUTLETS
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    // VARIABLES
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // I get the reference to the Storage where i have the file CSV
        storageRef = Storage.storage().reference().child("Data").child("Data_ARPAC_Formatted_CSV.csv");
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initGoogleMaps();
        readFromCSV();
        
    }
    
    func initGoogleMaps() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true

        createrMarker(38, 56);
     
    }
    
   func createrMarker(_ latitude: Float ,_ longitude: Float) {
        let marker = GMSMarker()
      
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        marker.position = location
        marker.title = "Location.name"
        marker.snippet = "Info window text"
        marker.map = googleMapsView
        marker.icon = #imageLiteral(resourceName: "flag-map-marker");
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
    
    func readFromCSV() {

        // Download to the local filesystem
        storageRef?.downloadURL(completion: { (url, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    guard let text = String(data: data!, encoding: String.Encoding.ascii) as String!
                        else {
                            print("error during conversion file \(data?.description)")
                            return
                        }
                    self.converTextToArray(text)
                    
                }
                
            }).resume()
        });
    }
    
    func converTextToArray(_ text: String){
        var dataArray: [[String]] = [[]] ;
    
        let rows = cleanRows(file: text).components(separatedBy: "\n")
            if rows.count > 0 {
                dataArray.append(getStringFieldsForRow(row: rows.first!,delimiter:","));
                
                for row in rows{
                    dataArray.append(getStringFieldsForRow(row: row,delimiter: ","));
                }
            } else {
                print("No data in file")
            }
        createFlags(dataArray,3,4);
    }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with:"\n")
        return cleanFile
    }
    
    func getStringFieldsForRow(row: String, delimiter:String)-> [String]{
        return row.components(separatedBy: delimiter)
    }
    
    func createFlags(_ data: [[String]],_ indexLongitude: Int,_ indexLatitude: Int){
        
        print("I'm putting Marker")
        var latitude: Float = Float(data[3][indexLatitude])!
        var longitude: Float = Float(data[3][indexLongitude])!
        
        for  i in 4...data.count-1 {
            
            print("Latitudine: \(data[i][indexLatitude]) e Longitudine: \(data[i][indexLongitude])  index: \(i)");
            
            if( (Float(data[i][indexLongitude]) ?? 0) != 0) {
                
                if( latitude != Float(data[i][indexLatitude]) || longitude != Float(data[i][indexLongitude])) {
                    latitude = Float(data[i][indexLatitude])!
                    longitude = Float (data[i][indexLongitude])!
                    createrMarker(longitude,latitude);
                }
            } else {
                
                if( latitude != Float(data[i][indexLatitude]) || longitude != Float(data[i][indexLongitude+1])) {
                    latitude = Float(data[i][indexLatitude])!
                    longitude = Float (data[i][indexLongitude+1])!
                    createrMarker(longitude,latitude);
                    
                }
            }
            
        }
        print("I'm finished");
    }
    
}
