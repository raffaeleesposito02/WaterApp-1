//
//  ProfileViewController.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 08/12/2017.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseStorageUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var notifyNews: UISwitch!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var switchNotifyChanges: UISwitch!
    @IBOutlet weak var btnLogOut: UIButton!
    @IBOutlet weak var labelLanguage: UILabel!
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var favouritesTableView: UITableView!
    
    @IBOutlet weak var imageViewCell: UIImageView!
    
    // I create a Picker view for the language
    var pickerLanguage = UIPickerView();
    var data = ["Italian", "English", "Napolitan"];
    var deleteFavouriteIndexPath: NSIndexPath? = nil
    
    // Ref to Database
    var ref: DatabaseReference?
    //    Ref to Storage: where i save image
    var storageRef: StorageReference?;
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    // LogOut
    @IBAction func actionLogOut(_ sender: Any) {
        try! Auth.auth().signOut();
        // After the logIn the button LogOut is not enable, meanwhile the LogIn yes
        btnLogOut.isEnabled = false;
        btnLogIn.isEnabled = true;
        self.appDelegate.uid = "NoValue";
        self.appDelegate.username = "Username"
        self.usernameLabel.text = "Username";
        
    }
    
    override func viewDidLoad() {
        
        btnLogIn.layer.cornerRadius = 8;
        btnLogOut.layer.cornerRadius = 8;
        btnProfile.layer.cornerRadius = btnProfile.bounds.width*0.5;
        super.viewDidLoad()
        favouritesTableView.delegate = self
        favouritesTableView.dataSource = self
        
        ref = Database.database().reference();
        storageRef = Storage.storage().reference();
       
        // I delegate the picker to itself. Same for the datasource of the picker
        pickerLanguage.delegate = self
        pickerLanguage.dataSource = self
        
        //        TODO: fix the position in landscape mode
        var pickerRect = pickerLanguage.frame;
        pickerRect.origin.x = self.view.frame.width/2 - pickerRect.width/2;
        pickerRect.origin.y = self.view.frame.height/2 - pickerRect.height/2;

        pickerLanguage.layer.cornerRadius = 8;
        pickerLanguage.layer.borderWidth = 0.5;
        
        pickerLanguage.frame = pickerRect;
        
        pickerLanguage.isHidden = true;
        // I need to set a background color otherwise there is a written overlap
        pickerLanguage.backgroundColor = UIColor.white;
        
        view.addSubview(pickerLanguage)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gestureReconizer:)))
        labelLanguage.addGestureRecognizer(tap)
        labelLanguage.isUserInteractionEnabled = true;
    }
    
    //MANAGE FAVOURITES TABLEVIEW ------------------------------------------------------------ BEGIN
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Favourite.shared.favouritePlace.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteTableCell", for: indexPath)
        cell.textLabel?.text = Favourite.shared.favouritePlace[indexPath.row]
        cell.imageView?.image = UIImage(named: Favourite.shared.favouriteMarkersImages[indexPath.row])
        //cell.detailTextLabel?.text = newsContent[indexPath.row]
        
        return cell
    }
    
    //THIS FUNCTION MAKES TABLEVIEWROWS EDITABLE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //THIS FUNCTION HANDLES SLIDE-TO-LEFT GESTURE ON A ROW
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFavouriteIndexPath = indexPath as NSIndexPath
            let favouriteToDelete = Favourite.shared.favouritePlace[indexPath.row]
            confirmDelete(favourite: favouriteToDelete)
        }
    }
    
    //THIS FUNCTION SHOWS A CONFIRM ALERT BEFORE DELETING A FAVOURITE
    func confirmDelete(favourite: String) {
        let alert = UIAlertController(title: "Delete Planet", message: "Are you sure you want to permanently delete \(favourite)?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteFavourite)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteFavourite)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //IF YOU CLICK "DELETE" ON THE ALERT, THIS FUNCTION WILL BE CALLED
    func handleDeleteFavourite(alertAction: UIAlertAction!) -> Void {
        if let indexPath = deleteFavouriteIndexPath {
            favouritesTableView.beginUpdates()
            
            Favourite.shared.favouritePlace.remove(at: indexPath.row)
            
            // Note that indexPath is wrapped in an array:  [indexPath]
            favouritesTableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            
            deleteFavouriteIndexPath = nil
            favouritesTableView.endUpdates()
        }
    }
    
    //IF YOU CLICK "CANCEL" ON THE ALERT, THIS FUNCTION WILL BE CALLED
    func cancelDeleteFavourite(alertAction: UIAlertAction!) {
        deleteFavouriteIndexPath = nil
    }
    
    //MANAGE FAVOURITES TABLEVIEW ------------------------------------------------------- END
    
    @IBAction func selectProfilePhotoButtonTapped(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated:true, completion: nil)
        btnProfile.clipsToBounds = true;
        btnProfile.contentMode = .center;
        btnProfile.layer.cornerRadius = btnProfile.bounds.width*0.5
    }
    
    
    @objc func tap(gestureReconizer: UITapGestureRecognizer) {
        pickerLanguage.isHidden = false
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        labelLanguage.text = data[row]
        ref?.child("Users").child(self.appDelegate.uid).child("Language").setValue(data[row]);
        pickerView.isHidden = true;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
    
    //    Detect the rotation of screen
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        // Here I check if the user have done the Log in
        if(self.appDelegate.uid != "NoValue") {
            //Enable the button Log out and disable the button of LogIn
            btnLogOut.isEnabled = true;
            btnLogIn.isEnabled = false;
           
            ref?.child("Users").child(self.appDelegate.uid).observe(.value , with: { (snapshot) in
                
                // Retrive all informations about that users
                let value = snapshot.value as? NSDictionary;
                
                // Set Everything
                self.usernameLabel.text  = value?["Username"] as? String
                let notifyNew = value?["NotifyNews"] as? Bool
                let notifyChanges =  value?["NotifyChanges"] as? Bool
                self.labelLanguage.text = value?["Language"] as? String
                // Placeholder image
                let placeholderImage = UIImage(named: "placeholder.jpg");
                // get the reference of the image
                let reference = self.storageRef?.child("Profile Images").child(self.appDelegate.uid).child("Image.jpg");
                // Set the image
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                reference?.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print("Error during download the image: \(error.localizedDescription)");
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!);
                        // TODO: Fix the layer of btn profile
                        self.btnProfile.setImage(image, for: UIControlState.normal);
                        
                    }
                }
                self.notifyNews.setOn(notifyNew ?? false, animated: true);
                self.switchNotifyChanges.setOn(notifyChanges ?? false, animated: true);
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        btnProfile.setImage(info[UIImagePickerControllerOriginalImage] as? UIImage, for: UIControlState.normal);
        // create a UIImage and upload it
        let imageData = UIImageJPEGRepresentation((info[UIImagePickerControllerOriginalImage] as? UIImage)! , 0.0)
        storageRef?.child("Profile Images").child(self.appDelegate.uid).child("Image.jpg").putData(imageData!, metadata: nil) { metadata, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print("Error during upload the image: \(error.localizedDescription)");
            } else {
                let downloadURL = metadata!.downloadURL()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionNotifyNews(_ sender: Any) {
        ref?.child("Users").child(self.appDelegate.uid).child("NotifyNews").setValue(self.notifyNews.isOn);
    }
    
    @IBAction func actionNotifyChanges(_ sender: Any) {
        ref?.child("Users").child(self.appDelegate.uid).child("NotifyChanges").setValue(self.switchNotifyChanges.isOn);
    }
    
    //Favourite TableView
}

