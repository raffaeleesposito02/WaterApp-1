//
//  MapViewController.swift
//  WaterApp
//
//  Created by Grazia Mazzei on 09/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import MapKit

import FirebaseStorage

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // OUTLETS FOR POPVIEW
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imageFlag: UIImageView!
    @IBOutlet weak var lblValueEnterococchi: UILabel!
    @IBOutlet weak var lblValueEscherichia: UILabel!
    @IBOutlet weak var dateLastAnalysis: UILabel!
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var star: UIButton!
    
    @IBOutlet weak var enterococchiEscherichiaConstraint: NSLayoutConstraint!
    
    // Favorite Places
    @IBOutlet weak var favoriteView: UIView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var mapTypeSelectorOutlet: UISegmentedControl!
    
    // Outlet for MAPS
    @IBOutlet weak var starredButtonOutlet: UIButton!
    @IBOutlet weak var myLocationButtonOutlet: UIButton!
    @IBOutlet weak var legend: UIView!
    
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
    
    // I get the User_Id
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    var gradientLayer: CAGradientLayer?;
    
    //  For Favorite Table View
    var deleteFavouriteIndexPath: IndexPath?;
    @IBOutlet weak var favoriteTableView: UITableView!
    var FavoritesDate: [Favorite]?;
    
    let coreData: CoreDataController = CoreDataController.shared;
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        Thread.sleep(forTimeInterval: 1.4)
        
        mapTypeSelectorOutlet.layer.cornerRadius = 4
        legend.layer.cornerRadius = 10
       
        // I get the reference to the Storage where i have the file CSV
        storageRef = Storage.storage().reference().child("Data").child("Data_ARPA_Formatted_CSV.csv");
        
        popView.isHidden = true;
        readFromCSV();
        
        popView.layer.cornerRadius = 24
        popView.layer.shadowColor = UIColor.black.cgColor
        popView.layer.shadowOpacity = 0.5
        popView.layer.shadowOffset = CGSize.zero
        popView.layer.shadowRadius = 60;
        gradientToView(view: self.popView);
        
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
        
        mapView.showsCompass = false
        barView.layer.cornerRadius = 2;
    }
    
    @objc func DismissKeyboard(){
        self.farFromTop.priority = UILayoutPriority(rawValue: 999)
        self.closeToTop.priority = UILayoutPriority(rawValue: 1);
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        view.endEditing(true)
    }
    
    // MAP TYPE SEGMENTED
    @IBAction func mapTypeSelector(_ sender: Any) {
        switch ((sender as AnyObject).selectedSegmentIndex) {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }

    @IBAction func closePopup(_ sender: Any) {
        popView.isHidden = true;
        self.star.setImage(UIImage(named: "add-to-favorites"), for: .normal);
        self.searchView.isHidden = false;
    }
    
    @IBAction func addOrRemoveStarred(_ sender: Any) {
        // I get the datas
        let datas = searchInArray(dataArpac, iLatitude, iLongitude, latitude, longitude);
        // I create an object of type Preference
        let preference: Preference = Preference(data: datas);

        let lastAnalysis: Int = (preference.analisysData.count - 1);
        
        if( star.currentImage == UIImage(named: "add-to-favorites") ){
            star.setImage(UIImage(named: "star_colored_bordi"), for: .normal);
            coreData.addFavorite(area: preference.area, locality: preference.locality, latitude: Float(preference.latitude)!, longitude: Float(preference.longitude)!,
                                 enterococci: Int16(Int(preference.analisysData[lastAnalysis][1])!), escherichia: Int16(Int(preference.analisysData[lastAnalysis][2])!));
        } else {
            star.setImage(UIImage(named: "add-to-favorites"), for: .normal);
            coreData.deleteFavorite(latitude: Float(preference.latitude)!, longitude: Float(preference.longitude)!)
        }
        
         self.favoriteTableView.reloadData();
    }
    
    // HIDE LEGEND AND BUTTONS WHEN MAP IS MOVING
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        legend.isHidden = true
        starredButtonOutlet.isHidden = true
        myLocationButtonOutlet.isHidden = true
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        legend.isHidden = false
        starredButtonOutlet.isHidden = false
        myLocationButtonOutlet.isHidden = false
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
    
    // Create a gradient view
    func gradientToView(view : UIView) {
        
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame.size = view.frame.size
        gradientLayer!.colors = [UIColor(named: "BluOcean")?.cgColor, UIColor(named:"DarkBlu")?.cgColor]
        gradientLayer!.locations = [0.0, 1.0]
        gradientLayer!.cornerRadius = 6;
        view.layer.insertSublayer(gradientLayer!, at: 0);
    
    }

    // Update the constraint and the gradient after a rotation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.enterococchiEscherichiaConstraint.constant = self.popView.frame.width - (274);
        gradientLayer!.frame = self.popView.layer.bounds
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
                            print("Error during conversion file \(data?.description)")
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
    
/*  SEARCH LOCATIONS OF ANALYSIS AND CREATE FLAGS */
    
    func createFlags(_ data: [[String]],_ indexLongitude: Int,_ indexLatitude: Int,_ indexEnterococchi: Int,
                     _ indexEscherichia: Int ){
        print(data[0][indexLatitude]);
        var latitude: Float = Float(data[0][indexLatitude])!
        var longitude: Float = Float(data[0][indexLongitude])!
        var valueEnterococchi: Int = Int(data[0][indexEnterococchi])!;
        var valueEscherichia: Int = Int(data[0][indexEscherichia])!;
        
        for  i in 1...data.count-1 {

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
                    valueEnterococchi = Int(data[i][indexEscherichia+1])!;
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
    
    
//    BUTTON FOR STARRED AND MAP TYPE
    
    @IBAction func starredButton(_ sender: Any) {
        self.closeToTop.constant = self.view.frame.height - (self.searchBar.frame.height + self.favoriteView.frame.height + 13)
        favoriteView.isHidden = false;
        self.searchResultsTableView.isHidden = true;
        self.searchResultsTableView.isHidden = true;
        setPrioritySearchBar();
    }
    
    @IBAction func myLocationButton(_ sender: Any) {
        let location = CLLocation()
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: self.mapView.region.span)
        
        mapView!.setRegion(region, animated: true)
        mapView!.setCenter(mapView!.userLocation.coordinate, animated: true)
    }
    
// SEARCH BAR
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        popView.isHidden = true;
        favoriteView.isHidden = true;
        searchResultsTableView.isHidden = false;
        self.closeToTop.constant = 100;
        setPrioritySearchBar();
   
    }
    
    @IBAction func swipeDownSearchBar(_ sender: UISwipeGestureRecognizer) {
        self.DismissKeyboard()
    }
    
    @IBAction func swipeUpTouchBar(_ sender: UISwipeGestureRecognizer) {
        
        // I need to modify the constraint in order to show the favorite places
        self.closeToTop.constant = self.view.frame.height - (self.searchBar.frame.height + self.favoriteView.frame.height + 13)
        favoriteView.isHidden = false;
        self.searchResultsTableView.isHidden = true;
        setPrioritySearchBar();
    }
    
    func setPrioritySearchBar() {
        
        self.farFromTop.priority = UILayoutPriority(rawValue: 1)
        self.closeToTop.priority = UILayoutPriority(rawValue: 999)
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    

    //MANAGE FAVOURITES TABLEVIEW ------------------------------------------------------- END
    
    
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

extension MapViewController: UITableViewDataSource,UITableViewDelegate  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "SearchTableView" {
            return searchResults.count;
            
        }
        else {
            FavoritesDate = coreData.loadAllFavorites();
            return FavoritesDate!.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.restorationIdentifier == "SearchTableView" {
            let searchResult = searchResults[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            
            cell.backgroundColor = UIColor(named: "BluOcean");
            
            cell.textLabel?.text = searchResult.title
            cell.textLabel?.textColor = UIColor.white;
            
            cell.detailTextLabel?.text = searchResult.subtitle
            cell.detailTextLabel?.textColor = UIColor.white;
            return cell
        }
        else {
            let resuseIdentifier = "FavoriteCell"

            guard let cell = tableView.dequeueReusableCell(withIdentifier: resuseIdentifier, for: indexPath) as? FavoriteCell else {
                    print("Fatal Error during the creation of FavoriteCell")
                    return FavoriteCell();
                };
         
            cell.lblLocation.text = "\(FavoritesDate![indexPath.row].area!)-\(FavoritesDate![indexPath.row].locality!)";
            
            if(FavoritesDate![indexPath.row].enterococci >= limitEnterococchi  || FavoritesDate![indexPath.row].escherichia >= limitEscherica) {
                
                    cell.imgFlag.image = UIImage(named: "flag-map-marker");
                } else if(FavoritesDate![indexPath.row].enterococci >= limitEnterococchi-100  || FavoritesDate![indexPath.row].escherichia >= limitEscherica-250){
                    cell.imgFlag.image =  UIImage(named: "flagwarning");
                
            } else {
                cell.imgFlag.image =  UIImage(named:"flagAppost")
            }
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.confirmDelete(index: indexPath);
        }
        
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
            // share item at indexPath
            print("I want to share: \(self.FavoritesDate![indexPath.row])")
        }
        
        share.backgroundColor = UIColor.lightGray
        
        return [delete, share]
        
    }

    //THIS FUNCTION SHOWS A CONFIRM ALERT BEFORE DELETING A FAVOURITE
    func confirmDelete(index: IndexPath) {
        let alert = UIAlertController(title: "Delete Favourite", message: "Are you sure you want to permanently delete \(self.FavoritesDate![index.row].area!)-\(self.FavoritesDate![index.row].locality!) ?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteFavourite)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteFavourite)
        
        self.deleteFavouriteIndexPath = index;
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)

        self.present(alert, animated: true, completion: nil)
    }

    //IF YOU CLICK "DELETE" ON THE ALERT, THIS FUNCTION WILL BE CALLED
    func handleDeleteFavourite(alertAction: UIAlertAction!) -> Void {
        if deleteFavouriteIndexPath != nil {
            // I delete the Favorite from database
            coreData.deleteFavorite(latitude: FavoritesDate![(deleteFavouriteIndexPath?.row)!].latitude, longitude: FavoritesDate![(deleteFavouriteIndexPath?.row)!].longitude);
            // I delete the Favorite also from array
            self.FavoritesDate!.remove(at: deleteFavouriteIndexPath!.row);
            self.favoriteTableView.deleteRows(at: [deleteFavouriteIndexPath!], with: .fade)
            deleteFavouriteIndexPath = nil
        }
    }

    //IF YOU CLICK "CANCEL" ON THE ALERT, THIS FUNCTION WILL BE CALLED
    func cancelDeleteFavourite(alertAction: UIAlertAction!) {
        deleteFavouriteIndexPath = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if( tableView.restorationIdentifier == "SearchTableView") {
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
                
                self.popView.isHidden = true;
                self.DismissKeyboard();
            }
        } else {
            /* I selected a location in favorite and I need to set all info in the popView and Hide the search bar */
            tableView.deselectRow(at: indexPath, animated: true);
            self.searchView.isHidden = true;
            centerMapOnLocation(location: CLLocation(latitude: CLLocationDegrees(self.FavoritesDate![indexPath.row].latitude), longitude: CLLocationDegrees(self.FavoritesDate![indexPath.row].longitude)));
            setPopView(latitude: self.FavoritesDate![indexPath.row].latitude, longitude: self.FavoritesDate![indexPath.row].longitude);
            
        }
    }
}


extension UISearchBar {
    
    var textColor:UIColor? {
        get {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                return textField.textColor
            } else {
                return nil
            }
        }
        
        set (newValue) {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                textField.textColor = newValue
            }
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
            
               view.image = UIImage(named: "flag-map-marker");
            } else if(annotation.vEnterococchi >= limitEnterococchi-100  || annotation.vEscherichia >= limitEscherica-250){
                view.image =  UIImage(named: "flagwarning");
            
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

        setPopView(latitude: latitude, longitude: longitude)
        mapView.deselectAnnotation(view.annotation, animated: true);
    }
    
    func setPopView(latitude: Float, longitude: Float) {
        var searchData = self.searchInArray(dataArpac, iLatitude, iLongitude, latitude, longitude);
        /* I need to show the information about that marker.
         Set all information */
        self.lblArea.text = searchData[0][0];
        self.lblArea.sizeToFit();
        
        self.lblCity.text = searchData[0][1];
        self.lblCity.sizeToFit();
        
        self.lblLocation.text = searchData[0][2];
        self.lblLocation.sizeToFit();
        
        self.dateLastAnalysis.text = searchData[0][5];
        self.dateLastAnalysis.sizeToFit();
        
        var lastIndex:Int = searchData.count-1;
        var valueEnterococchi = Int(searchData[lastIndex][iEnterococchi])!;
        var valueEscherichia = Int(searchData[lastIndex][iEscherichia])!;
        
        if(valueEnterococchi >= limitEnterococchi  || valueEscherichia >= limitEscherica) {
            
                self.imageFlag.image = UIImage(named: "flag-map-marker1");
                
            } else if(valueEnterococchi >= limitEnterococchi-100  || valueEscherichia >= limitEscherica-250){
                self.imageFlag.image = UIImage(named: "flagwarning1");
            
        } else {
            self.imageFlag.image = UIImage(named: "flagappost-1");
        }
        
        self.lblValueEscherichia.text = searchData[lastIndex][iEscherichia];
        self.lblValueEscherichia.sizeToFit();
        
        self.lblValueEnterococchi.text = searchData[lastIndex][iEnterococchi];
        self.lblValueEnterococchi.sizeToFit();
        self.searchView.isHidden = true;
        
        if coreData.loadFavorite(latitude: latitude, longitude: longitude) == nil {
            star.setImage(UIImage(named: "add-to-favorites"), for: .normal);
        }
        else{
            self.star.setImage(UIImage(named: "star_colored_bordi"), for: .normal)
            
        }
        
        popView.isHidden = false;
    }

}

