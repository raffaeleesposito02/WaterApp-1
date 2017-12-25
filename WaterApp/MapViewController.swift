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
import FirebaseDatabase

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
    
    let iEscherichia: Int = 7;
    let iEnterococchi: Int = 6;
    
    let iLatitude: Int = 3;
    let iLongitude: Int = 4;
    
    
    // Limit for Enterococchi e Escherichia
    var limitEnterococchi: Int = 200; // (UFC o MPN /100ml, valore limite 200)
    var limitEscherica: Int = 500; // (UFC o MPN /100ml, valore limite 500)
    // Information from ARPAC
    var dataArpac =  Array<Array<String>>();
    
    // We need this file to save the location
    var latitude: Float = 0.0;
    var longitude: Float = 0.0;
    
    
    // I get the reference to database
    var ref: DatabaseReference?;
    // I get the User_Id
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    @IBAction func closePopup(_ sender: Any) {
        popView.isHidden = true;
        self.star.setImage(UIImage(named: "add-to-favorites"), for: .normal);
    }
    
    @IBOutlet weak var star: UIButton!
    
    @IBAction func addOrRemoveStarred(_ sender: Any) {
        // I get the datas
        let datas = searchInArray(dataArpac, iLatitude, iLongitude, latitude, longitude);
        
        // I create an object of type Preference
        var preference: Preference = Preference(data: datas);
        let refPreference = self.ref?.child(self.appDelegate.uid).child(String(preference.locality.hashValue));
        print("schiacciato");
        if( star.currentImage != UIImage(named: "star_colored_bordi") ){
            print("schiacciato dentro");
            // If the user have done the log in
            if( self.appDelegate.uid != "NoValue" ){
                
                refPreference?.setValue(preference.toDictionary());
                refPreference?.child("DataAnalysis").setValue(preference.toDictionaryArray());
                
                star.setImage(UIImage(named: "star_colored_bordi"), for: .normal);
            }
            else { // The user doesn't have an account so i need to save in local the location
                
            }
        } else {
             print("schiacciato fuori");
            refPreference?.removeValue()
            star.setImage(UIImage(named: "add-to-favorites"), for: .normal);
        }
    }
    
    //ARRAY THAT CONTAINS STARRED PLACES (STATIC, FOR NOW)
    var starredPlace: [String] = ["Napoli", "Caserta", "Salerno"]
    var markersPlace: [String] = ["flag-map-marker.png", "flagAppost.png", "flagwarning.png"]
    
    //WHEN MARKER IS TAPPED
    func mapView(_ mapView:GMSMapView, didTap marker: GMSMarker) -> Bool {

        // Retrive information about marker location
        latitude = Float(marker.position.latitude);
        longitude = Float(marker.position.longitude);
        popView.isHidden = false;
      
        var searchData = self.searchInArray(dataArpac, iLatitude, iLongitude, latitude,longitude);
        // I need to show the information about that marker.
    
        // First I need to see if the user has saved the place in the preferences
        if( self.appDelegate.uid != "NoValue" ){
            
            let refPreference = self.ref?.child(self.appDelegate.uid).observe(.value, with: { (snapshot) in
                // If YES
                if (snapshot.hasChild(String(searchData[0][2].hashValue))){
                    // Se the image blank
                   self.star.setImage(UIImage(named: "star_colored_bordi"), for: .normal);

                }
            });
        }
        
        // Set all information
        self.lblCity.text = searchData[1][1];
        self.lblCity.sizeToFit();
        
        self.lblLocation.text = searchData [1][2];
        self.lblLocation.sizeToFit();
        
        self.lblArea.text = searchData[1][0];
        self.lblArea.sizeToFit();
        
        var lastIndex:Int = searchData.count-1;
        var valueEnterococchi = Int(searchData[lastIndex][iEnterococchi]);
        var valueEscherichia = Int(searchData[lastIndex][iEscherichia]);
        
        if(valueEnterococchi! >= limitEnterococchi  || valueEscherichia! >= limitEscherica) {
            
            if(valueEnterococchi! >= limitEnterococchi  && valueEscherichia! >= limitEscherica){
                self.imageFlag.image = UIImage(named: "flag-map-marker1");
                
            } else {
                self.imageFlag.image = UIImage(named: "flagwarning1");
            }
        } else {
            self.imageFlag.image = UIImage(named: "flagappost-1");
        }
        
        
        self.lblValueEscherichia.text = searchData[lastIndex][iEscherichia];
        self.lblValueEscherichia.sizeToFit();
        
        self.lblValueEnterococchi.text = searchData[lastIndex][iEnterococchi];
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
        ref =  Database.database().reference().child("Preferences");
        
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
                
        // Get the reference to Firebase
        

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        popView.isHidden = true
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
        
        marker.position = location;
        marker.map = googleMapsView;
        
        if(valueEnterococchi >= limitEnterococchi  || valueEscherichia >= limitEscherica) {
            
            if(valueEnterococchi >= limitEnterococchi  && valueEscherichia >= limitEscherica){
                marker.icon = #imageLiteral(resourceName: "flag-map-marker");
            } else {
                marker.icon = #imageLiteral(resourceName: "flagwarning");
                
            }
        } else {
            marker.icon = #imageLiteral(resourceName: "flagAppost");
        }
        
    }
    
    
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 14.0)
        
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
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 13.0)
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
    
    func createFlags(_ data: [[String]],_ indexLongitude: Int,_ indexLatitude: Int,_ indexEnterococchi: Int,
                     _ indexEscherichia: Int ){
        
        var latitude: Float = Float(data[3][indexLatitude])!
        var longitude: Float = Float(data[3][indexLongitude])!
        var valueEnterococchi: Int = Int(data[3][indexEnterococchi])!;
        var valueEscherichia: Int = Int(data[3][indexEscherichia])!;
        
        for  i in 4...data.count-1 {
            
            if( (Float(data[i][indexLongitude]) ?? 0) != 0) {
                
                if( latitude != Float(data[i][indexLatitude]) || longitude != Float(data[i][indexLongitude])) {
                    // Create a merker in the previous point
                    createrMarker(longitude,latitude, valueEnterococchi, valueEscherichia );
                    // Set the new values
                    latitude = Float(data[i][indexLatitude])!
                    longitude = Float (data[i][indexLongitude])!
                    valueEnterococchi = Int(data[i][indexEnterococchi])!;
                    valueEscherichia = Int(data[i][indexEscherichia])!;
                } else {
                    // update only the values of bacterias
                    valueEnterococchi = Int(data[i][indexEnterococchi])!;
                    valueEscherichia = Int(data[i][indexEscherichia])!;
                }
            } else {
                
                if( latitude != Float(data[i][indexLatitude+1]) || longitude != Float(data[i][indexLongitude+1])) {
                    // Create a merker in the previous point
                    createrMarker(longitude,latitude, valueEnterococchi, valueEscherichia );
                    // Set the new values
                    latitude = Float(data[i][indexLatitude+1])!
                    longitude = Float (data[i][indexLongitude+1])!
                    valueEnterococchi = Int(data[i][indexEnterococchi+1])!;
                    valueEscherichia = Int(data[i][indexEscherichia+1])!;
                } else {
                    if( latitude != Float(data[i][indexLatitude+1]) || longitude != Float(data[i][indexLongitude+1])) {
                        // Create a merker in the previous point
                        createrMarker(longitude,latitude, valueEnterococchi, valueEscherichia );
                        // Set the new values
                        latitude = Float(data[i][indexLatitude+1])!
                        longitude = Float (data[i][indexLongitude+1])!
                        valueEnterococchi = Int(data[i][indexEnterococchi+1])!;
                        valueEscherichia = Int(data[i][indexEscherichia+1])!;
                    } else {
                        // update only the values of bacterias
                        valueEnterococchi = Int(data[i][indexEnterococchi+1])!;
                        valueEscherichia = Int(data[i][indexEscherichia+1])!;
                    }
                }
            }
        }
    }
    
    func searchInArray(_ data: Array<Array<String>>, _ indexLatitude: Int,_ indexLongitude: Int,_ latitudeValue: Float,
                           _ longitudeValue: Float) -> Array<Array<String>> {
            var values = Array<Array<String>>();
            
            // I start a cycle
            for i in 3...data.count-1{
                // If I haven't an error during the conversation of the String to Float
                if( (Float(data[i][indexLongitude]) ?? 0) != 0) {
                    if( latitudeValue == Float(data[i][indexLatitude]) && longitudeValue == Float(data[i][indexLongitude])) {
                        // I have fouund the location so i punt in the array-2D
                        values.append(data[i]);
                    }
                    
                } else {
                    
                    if( latitudeValue == Float(data[i][indexLatitude+1]) && longitudeValue == Float(data[i][indexLongitude+1])) {
                        values.append(data[i]);
                    }
                }
            }
            
            return values;
        }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.rightBarButtonItem?.setTitlePositionAdjustment(.init(horizontal: 100, vertical: 100), for: .default)
       
    }
    
    }
