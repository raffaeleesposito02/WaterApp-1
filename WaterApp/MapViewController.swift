//
//  MapViewController.swift
//  WaterApp
//
//  Created by Grazia Mazzei on 09/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import FirebaseStorage
import FirebaseDatabase

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imageFlag: UIImageView!
    @IBOutlet weak var lblValueEnterococchi: UILabel!
    @IBOutlet weak var lblValueEscherichia: UILabel!
    @IBOutlet weak var dateLastAnalysis: UILabel!
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
    
    // Location
    var locationManager = CLLocationManager()
    var storageRef: StorageReference?
    
    // I get the reference to database

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
        
        print("schiacciato");
        if( star.currentImage != UIImage(named: "star_colored_bordi") ){
            print("schiacciato dentro");
            // If the user have done the log in
            if( self.appDelegate.uid != "NoValue" ){
                

                
                star.setImage(UIImage(named: "star_colored_bordi"), for: .normal);
            }
            else { // The user doesn't have an account so i need to save in local the location
                
            }
        } else {
             print("schiacciato fuori");
         
            star.setImage(UIImage(named: "add-to-favorites"), for: .normal);
        }
    }
    
    // OUTLETS
    @IBOutlet weak var legend: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        legend.layer.cornerRadius = 10
        // I get the reference to the Storage where i have the file CSV
        storageRef = Storage.storage().reference().child("Data").child("Data_ARPAC_Formatted_CSV.csv");
        
        popView.isHidden = true;
        readFromCSV();
        
        popView.layer.cornerRadius = 24
        popView.layer.shadowColor = UIColor.black.cgColor
        popView.layer.shadowOpacity = 0.5
        popView.layer.shadowOffset = CGSize.zero
        popView.layer.shadowRadius = 60
        
//        MAPKIT
        searchCompleter.delegate = self
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges();
        
        centerMapOnLocation(location: locationManager.location!);
        mapView.showsUserLocation = true;
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.DismissKeyboard))
        self.mapView.addGestureRecognizer(tap)

    }
    
    @objc func DismissKeyboard(){
        self.farFromTop.priority = UILayoutPriority(rawValue: 999)
        self.closeToTop.priority = UILayoutPriority(rawValue: 1);
        view.endEditing(true)
    }
    
    let regionRadius: CLLocationDistance = 15000;
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        popView.isHidden = true
    }
    
    
    func createrMarker(_ latitude: Float ,_ longitude: Float,_ valueEnterococchi: Int, _ valueEscherichia: Int) {
        
        let analysisPoint = AnalysisPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude)), valueEnterococchi, valueEscherichia );
        
        mapView.addAnnotation(analysisPoint)
    }

//    -------------------READ FROM FILE-------------------
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
    
//    ----GET DATE IN A FORMAT EASY TO READ
    
    func formattedDate(date: String) -> String {
        
        let startingIndex = date.index(date.startIndex, offsetBy: 4)
        let new = date.substring(from: startingIndex)
        let endingIndex = new.index(new.endIndex, offsetBy: -19)
        let final = new.substring(to: endingIndex)
        
        return final + " 2017"
    }
    
/*  SEARCH LOCATIONS OF ANALYSIS AND CREATE FLAGS */
    
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
    
//   --------------------vvv MAPKIT vvv---------------------
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var farFromTop: NSLayoutConstraint!
    @IBOutlet weak var closeToTop: NSLayoutConstraint!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        popView.isHidden = true
        
        self.farFromTop.priority = UILayoutPriority(rawValue: 1)
        self.closeToTop.priority = UILayoutPriority(rawValue: 999)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension MapViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension MapViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension MapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            print(String(describing: coordinate))

            //      MOVE ON SEARCHED
            let initialLocation = CLLocation(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!)

            self.centerMapOnLocation(location: initialLocation)

            self.popView.isHidden = true
            self.DismissKeyboard()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil}
        
        guard let annotation = annotation as? AnalysisPoint else { return nil }
        let view : MKAnnotationView;

        if let annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") {
            annotationView.annotation = annotation;
            view = annotationView;
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin");
            view.canShowCallout = false;
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure);
        }
        
        if(annotation.vEnterococchi >= limitEnterococchi  || annotation.vEscherichia >= limitEscherica) {
            
            if(annotation.vEnterococchi >= limitEnterococchi  && annotation.vEscherichia >= limitEscherica){
               view.image = UIImage(named: "flag-map-marker");
            } else {
                view.image =  UIImage(named: "flagwarning");
            }
        } else {
            view.image =  UIImage(named:"flagAppost")
        }
        return view;
    }
    
    // WHEN A MARKER IS TAPPED
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        
        // Retrive information about marker location
        latitude = Float((view.annotation?.coordinate.latitude)!);
        longitude = Float((view.annotation?.coordinate.longitude)!);

        var searchData = self.searchInArray(dataArpac, iLatitude, iLongitude, latitude, longitude);
        /* I need to show the information about that marker.
           Set all information */
        self.lblArea.text = searchData[1][0];
        self.lblArea.sizeToFit();
        
        
        self.lblCity.text = searchData[1][1];
        self.lblCity.sizeToFit();

        self.lblLocation.text = searchData [1][2];
        self.lblLocation.sizeToFit();
        
        self.dateLastAnalysis.text = formattedDate(date: searchData [1][5]);
        self.dateLastAnalysis.sizeToFit();

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
        
        popView.isHidden = false
    }
}

