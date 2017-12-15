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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var notifyNews: UISwitch!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var switchNotifyChanges: UISwitch!
    @IBOutlet weak var btnLogOut: UIButton!
    @IBOutlet weak var labelLanguage: UILabel!
    @IBOutlet weak var labelMeasurement: UILabel!
    @IBOutlet weak var labelCity: UILabel!
    
    
    var ref: DatabaseReference?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    // LogOut
    @IBAction func actionLogOut(_ sender: Any) {
        try! Auth.auth().signOut();
        // After the logIn the button LogOut is not enable, meanwhile the LogIn yes
        btnLogOut.isEnabled = false;
        btnLogIn.isEnabled = true;
        self.appDelegate.uid = "NoValue";
        self.appDelegate.username = "Username"
        self.usernameLabel.text = "Username"
        
    }
    
    override func viewDidLoad() {
        
        btnLogIn.layer.cornerRadius = 8;
        btnLogOut.layer.cornerRadius = 8;
        btnProfile.layer.cornerRadius = btnProfile.bounds.width*0.5;
        super.viewDidLoad()
        ref = Database.database().reference();
        
    }
    
    @IBAction func selectProfilePhotoButtonTapped(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated:true, completion: nil)
        btnProfile.clipsToBounds = true;
        btnProfile.contentMode = .center;
        btnProfile.layer.cornerRadius = btnProfile.bounds.width*0.5
        
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
                self.labelMeasurement.text = value?["Unit of Misure"] as? String;
                
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
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func actionNotifyNews(_ sender: Any) {
        ref?.child("Users").child(self.appDelegate.uid).child("NotifyNews").setValue(self.notifyNews.isOn);
    }
    
    @IBAction func actionNotifyChanges(_ sender: Any) {
        ref?.child("Users").child(self.appDelegate.uid).child("NotifyChanges").setValue(self.switchNotifyChanges.isOn);
    }
}

