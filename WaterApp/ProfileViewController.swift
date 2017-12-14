//
//  ProfileViewController.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 08/12/2017.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var loginButtonShape: UIButton!
    @IBAction func loginButton(_ sender: Any) {}
    
    @IBOutlet weak var btnProfile: UIButton!
    
    @IBAction func selectProfilePhotoButtonTapped(_ sender: Any) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated:true, completion: nil)
        
        btnProfile.layer.cornerRadius = loginButtonShape.frame.size.width / 2
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButtonShape.layer.cornerRadius = 8;
        usernameLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        usernameLabel.text = Accounts.shared.currentUser
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        btnProfile.setImage(info[UIImagePickerControllerOriginalImage] as? UIImage, for: UIControlState.normal);
        btnProfile.layer.cornerRadius = loginButtonShape.frame.size.width / 2
        
        self.dismiss(animated: true, completion: nil)
       
    }
    
}
