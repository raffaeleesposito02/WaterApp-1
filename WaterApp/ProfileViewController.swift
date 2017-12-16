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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var notifyNews: UISwitch!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var switchNotifyChanges: UISwitch!
    @IBOutlet weak var btnLogOut: UIButton!
    @IBOutlet weak var labelLanguage: UILabel!
    @IBOutlet weak var labelMeasurement: UILabel!
    @IBOutlet weak var labelCity: UILabel!
    
    // I create a Picker view for the language
    var pickerLanguage = UIPickerView();
    var data = ["Italian", "English", "Napolitan"];
    
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
        self.usernameLabel.text = "Username";
        
    }
    
    override func viewDidLoad() {
        
        btnLogIn.layer.cornerRadius = 8;
        btnLogOut.layer.cornerRadius = 8;
        btnProfile.layer.cornerRadius = btnProfile.bounds.width*0.5;
        super.viewDidLoad()
        ref = Database.database().reference();
        
        // I delegate the picker to itself. Same for the datasource of the picker
        pickerLanguage.delegate = self
        pickerLanguage.dataSource = self
        
        var pickerRect = pickerLanguage.frame;
        pickerRect.origin.x = self.view.frame.minX + 20;
        pickerRect.origin.y = self.view.frame.height/3; // some desired value
        pickerLanguage.frame = pickerRect;
        
        pickerLanguage.isHidden = true;
        view.addSubview(pickerLanguage)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gestureReconizer:)))
        labelLanguage.addGestureRecognizer(tap)
        labelLanguage.isUserInteractionEnabled = true;
        
        
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
    
    @objc func tap(gestureReconizer: UITapGestureRecognizer) {
        print("*")
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
        self.view.endEditing(true);
        pickerView.isHidden = true;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
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

