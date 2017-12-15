//
//  LogInViewController.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 09/12/2017.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class LogInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var subViewLogIn: UIView!
    var ref: DatabaseReference?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate;
    
    
    override func viewDidLoad() {
        // set the layout of view
        layoutTextFiled(usernameTextField);
        layoutTextFiled(passwordTextField);
        
        layoutButton(btnLogIn);
        layoutButton(btnGoogle);
        layoutButton(btnFacebook);
    
        //----
        ref = Database.database().reference();
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        super.viewDidLoad()
    }
    
    func layoutButton(_ btn: UIButton){
        btn.layer.cornerRadius = 8;
        btn.layer.shadowColor = UIColor.black.cgColor;
        btn.layer.shadowOffset = CGSize(width: 0.5, height: 0.5);
        btn.layer.shadowOpacity = 0.3;
    }
    
    func layoutTextFiled(_ field: UITextField) {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: field.frame.height))
        field.leftView = paddingView
        field.leftViewMode = UITextFieldViewMode.always
        
        field.layer.borderColor = UIColor(red: 0.648, green: 0.710, blue: 0.781, alpha: 0.2).cgColor;
        field.layer.shadowColor = UIColor.black.cgColor;
        field.layer.cornerRadius = 8;
        field.layer.borderWidth = 1;
        
    }

    // when i press the logIn button It have to do login with the email and password that I have put
    @IBAction func buttonLogin(_ sender: Any) {
        //TODO: do some additional controls on validations
        if let email = usernameTextField.text, let pass = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: pass, completion: {
                (user, error) in
                //check if the username is nil
                if let u = user {
                    // the username was found, so i need to come back and set the User_id
                    self.appDelegate.uid = user?.uid ?? "NoValue";
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    //  give a message of error
                    print("Errore:\(error.debugDescription)" )
                    
                }
            })
        }
    }
    
    @IBAction func signWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn();
    }
    
    
    
    @IBAction func facebookLogin (sender: AnyObject){
        let facebookLogin = FBSDKLoginManager()
        print("Logging In");
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil { print("Facebook login failed. Error \(facebookError)")
            } else if (facebookResult?.isCancelled)! { print("Facebook login was cancelled.")
            } else { print("You’re inz ;)")}
        });
    }
    
//  hide keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
