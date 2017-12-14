//
//  CreateAccountViewController.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 09/12/2017.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class CreateAccountViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordMismatch: UILabel!
    @IBOutlet weak var existingUsername: UILabel!
    @IBOutlet weak var btnSignUp: UIButton!
    var ref: DatabaseReference?;
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Textfield Layout
        layoutTextFiled(usernameTextField);
        layoutTextFiled(passwordTextField);
        layoutTextFiled(retypePasswordTextField);
        layoutTextFiled(emailTextField);
        
        // Set the cornerRadius and the Shadow for the button 
        btnSignUp.layer.cornerRadius = 8;
        btnSignUp.layer.shadowColor = UIColor.black.cgColor;
        btnSignUp.layer.shadowOffset = CGSize(width: 0.5, height: 0.5);
        btnSignUp.layer.shadowOpacity = 0.3;
        ref = Database.database().reference();
        
    }
    
    // Method that set the layout of specific textFiled, in this way I don't have to repeat for all fields
    func layoutTextFiled(_ field: UITextField) {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: field.frame.height))
        field.leftView = paddingView
        field.leftViewMode = UITextFieldViewMode.always
        
        field.layer.borderColor = UIColor(red: 0.648, green: 0.710, blue: 0.781, alpha: 0.2).cgColor;
        field.layer.shadowColor = UIColor.black.cgColor;
        field.layer.cornerRadius = 8;
        field.layer.borderWidth = 1;

    }
    
    @IBAction func createAccount(_ sender: Any) {
        // If the 2 password aren't equal show the warning
        if( passwordTextField.text != retypePasswordTextField.text  || usernameTextField.text == nil ){
            passwordMismatch.isHidden = false;
        } else { // Do the registration
            passwordMismatch.isHidden = true;
            if let email = emailTextField.text, let pass = passwordTextField.text {
                Auth.auth().createUser(withEmail: email, password: pass, completion: {
                    (user, error) in
                    if let u = user {
                        self.appDelegate.username = self.usernameTextField.text!
                        
                        self.ref?.child("Users").child("\(self.usernameTextField.text ?? "NoValue")").child("Email").setValue("\(self.emailTextField.text ?? "NoValue")");
                        print("User creato");
                        
                        print("User creato")
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        print("C'è stato un errore \(error.debugDescription)");
                    }
                    
                });
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
