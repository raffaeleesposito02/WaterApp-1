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
    
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imageFlag: UIImageView!
    @IBOutlet weak var lblValueEnterococchi: UILabel!
    @IBOutlet weak var lblValueEscherichia: UILabel!
    @IBOutlet weak var imageEnterococchiSemaphore: UIImageView!
    
    @IBOutlet weak var imgEscherichiaSemaphore: UIImageView!
    @IBOutlet weak var popView: UIView!
    var limitEnterococchi: Int = 200; // (UFC o MPN /100ml, valore limite 200)
    var limitEscherica: Int = 500; // (UFC o MPN /100ml, valore limite 500)
    
    var dataArpac: [[String]] = [[]];
    
    @IBAction func closePopup(_ sender: Any) {
        popView.isHidden = true
    }
    
    @IBOutlet weak var star: UIButton!
    
    @IBAction func addOrRemoveStarred(_ sender: Any) {
//        THERE IS ALREADY A FULL STAR ICON IN THE ASSETS READY TO USE
    }
 
   
    
    //ARRAY THAT CONTAINS STARRED PLACES (STATIC, FOR NOW)
    var starredPlace: [String] = ["Napoli", "Caserta", "Salerno"]
    var markersPlace: [String] = ["flag-map-marker.png", "flagAppost.png", "flagwarning.png"]
    
    //WHEN MARKER IS TAPPED
    func mapView(_ mapView:GMSMapView, didTap marker: GMSMarker) -> Bool {
        // I show the popView
        popView.isHidden = false;
        // I need to show the information about that marker.
        // Retrive information about marker location
        
        var searchData = self.searchInArray(dataArpac, 4, 3, Float(marker.position.latitude), Float(marker.position.longitude));
        
 
        // Set all information
        self.lblCity.text = searchData[1][1];
        self.lblCity.sizeToFit();
        
        self.lblLocation.text = searchData [1][2];
        self.lblLocation.sizeToFit();
        
        self.lblArea.text = searchData[1][0];
        self.lblArea.sizeToFit();
        
        var lastIndex:Int = searchData.count-1;
        var valueEnterococchi = Int(searchData[lastIndex][6]);
        var valueEscherichia = Int(searchData[lastIndex][7]);
        
        if(valueEnterococchi! >= limitEnterococchi  || valueEscherichia! >= limitEscherica) {
            
            if(valueEnterococchi! >= limitEnterococchi  && valueEscherichia! >= limitEscherica){
                self.imageFlag.image = UIImage(named: "flag-map-marker1");

            } else {
                self.imageFlag.image = UIImage(named: "flagwarning1");
            }
        } else {
            self.imageFlag.image = UIImage(named: "flagappost-1");
        }
        
       
        self.lblValueEscherichia.text = searchData[lastIndex][7];
        self.lblValueEscherichia.sizeToFit();
        
        self.lblValueEnterococchi.text = searchData[lastIndex][6];
        self.lblValueEnterococchi.sizeToFit();
        
        return false
    }

    
    // OUTLETS
    @IBOutlet weak var legend: UIView!
    
    func mapView(_ mapView: GMSMapView, didBeginDragging: GMSMapView) {
        
        googleMapsView.delegate = self

        legend.isHidden = true
        
    }
    
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    // VARIABLES
    var locationManager = CLLocationManager()
    var storageRef: StorageReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad();

        
        legend.layer.cornerRadius = 10
        // I get the reference to the Storage where i have the file CSV
        storageRef = Storage.storage().reference().child("Data").child("Data_ARPAC_Formatted_CSV.csv");
        
        popView.isHidden = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initGoogleMaps();
        readFromCSV();
        
        
        popView.layer.cornerRadius = 24
        popView.layer.shadowColor = UIColor.black.cgColor
        popView.layer.shadowOpacity = 0.5
        popView.layer.shadowOffset = CGSize.zero
        popView.layer.shadowRadius = 60
        
        //PASS STARRED PLACES TO FavouriteSingleton, JUST FOR CHECKING IF IT WORKS!
        addToFavourites()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        popView.isHidden = true
    }
    
    func addToFavourites(){
        Favourite.shared.favouritePlace = starredPlace
        Favourite.shared.favouriteMarkersImages = markersPlace
    }
    
    func initGoogleMaps() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true

     
    }
    
    func createrMarker(_ latitude: Float ,_ longitude: Float,_ valueEnterococchi: Int, _ valueEscherichia: Int) {
        let marker = GMSMarker()
      
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        marker.position = location
        marker.title = "Location.name"
        marker.snippet = "Info window text"
        marker.map = googleMapsView;
        
        if(valueEnterococchi >= limitEnterococchi  || valueEscherichia >= limitEscherica) {
            
            if(valueEnterococchi >= limitEnterococchi  && valueEscherichia >= limitEscherica){
                marker.icon = #imageLiteral(resourceName: "flag-map-marker")
            } else {
                marker.icon = #imageLiteral(resourceName: "flagwarning")
            }
        } else {
           marker.icon = #imageLiteral(resourceName: "flagAppost")
        }

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

    }
    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapsView.isMyLocationEnabled = true
        
        legend.isHidden = false
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
            
            legend.isHidden = true
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
        
    
        let rows = cleanRows(file: text).components(separatedBy: "\n")
            if rows.count > 0 {
                self.dataArpac.append(getStringFieldsForRow(row: rows.first!,delimiter:","));
                
                for row in rows{
                    self.dataArpac.append(getStringFieldsForRow(row: row,delimiter: ","));
                }
            } else {
                print("No data in file")
            }
        createFlags(self.dataArpac,3,4,6,7);
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
    
    func createFlags(_ data: [[String]],_ indexLongitude: Int,_ indexLatitude: Int,_ indexEscherichia: Int,
                     _ indexEnterococchi: Int ){
        
        var latitude: Float = Float(data[3][indexLatitude])!
        var longitude: Float = Float(data[3][indexLongitude])!
        
        for  i in 4...data.count-1 {
            
            if( (Float(data[i][indexLongitude]) ?? 0) != 0) {
                
                if( latitude != Float(data[i][indexLatitude]) || longitude != Float(data[i][indexLongitude])) {
                    latitude = Float(data[i][indexLatitude])!
                    longitude = Float (data[i][indexLongitude])!
                    createrMarker(longitude,latitude, Int(data[i][indexEnterococchi])!, Int(data[i][indexEscherichia])!);
                }
            } else {
                
                if( latitude != Float(data[i][indexLatitude]) || longitude != Float(data[i][indexLongitude+1])) {
                    latitude = Float(data[i][indexLatitude])!
                    longitude = Float (data[i][indexLongitude+1])!
                    createrMarker(longitude,latitude, Int(data[i][indexEnterococchi+1])!, Int(data[i][indexEscherichia+1])!);
                }
            }
        }
    }
    
    func searchInArray(_ data: [[String]], _ indexLongitude: Int,_ indexLatitude: Int,_ latitudeValue: Float,
                       _ longitudeValue: Float) -> [[String]] {
        var values: [[String]] = [[]];
        
        // I start a cycle
        for i in 3...data.count-1{
            
            // If I haven't an error during the conversation of the String to Float
            if( (Float(data[i][indexLongitude]) ?? 0) != 0) {
                if( latitudeValue == Float(data[i][indexLatitude]) && longitudeValue == Float(data[i][indexLongitude])) {
                    // I have fouund the location so i punt in the array-2D
    
                    values.append(data[i]);
                }
                
            } else {
                
                if( latitudeValue == Float(data[i][indexLatitude]) && longitudeValue == Float(data[i][indexLongitude+1])) {
    
                    values.append(data[i]);
                }
            }
        }

        return values;
    }
}
