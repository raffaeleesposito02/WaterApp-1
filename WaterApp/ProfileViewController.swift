//
//  ProfileViewController.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 08/12/2017.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var loginButtonShape: UIButton!
    
    @IBAction func loginButton(_ sender: Any) {
        Accounts.shared.isLogged = false
    }
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var notifyNews: UISwitch!
    var ref: DatabaseReference?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    
    override func viewDidLoad() {
        
        loginButtonShape.layer.cornerRadius = 8;
        usernameLabel.adjustsFontSizeToFitWidth = true
        btnProfile.layer.cornerRadius = btnProfile.bounds.width*0.5;
        super.viewDidLoad()
        ref = Database.database().reference();
        // here I check if the user have done the Log in
        if(self.appDelegate.username != "NoValue") {
            ref?.child("Users").child("\(self.appDelegate.username)").observe(.childChanged , with: { (snapshot) in
                self.usernameLabel.text = self.appDelegate.username;
                let value = snapshot.value as? NSDictionary;
                let notifyNew = value?["NotifyMe"] as? Bool
                self.notifyNews.setOn(notifyNew!, animated: true);
            })
        }
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
    

    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        usernameLabel.text = Accounts.shared.currentUser
        
        if Accounts.shared.isLogged {
            
            loginButtonShape.setTitle("Logout", for: .normal)
            
        } else {
            
            loginButtonShape.setTitle("Login", for: .normal)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        btnProfile.setImage(info[UIImagePickerControllerOriginalImage] as? UIImage, for: UIControlState.normal);
        self.dismiss(animated: true, completion: nil)
    }
    
}


