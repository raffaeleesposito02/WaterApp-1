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


class LogInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate, UIScrollViewDelegate{

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
        GIDSignIn.sharedInstance().delegate = self;
        super.viewDidLoad()

            
            //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LogInViewController.DismissKeyboard))
            view.addGestureRecognizer(tap)
        }
    
    @objc func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        
        field.layer.borderColor = UIColor(red: 0.590, green: 0.890, blue: 0.152, alpha: 0.2).cgColor;
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
                if user != nil {
                    // the username was found, so i need to come back and set the User_id
                    self.appDelegate.uid = user?.uid ?? "NoValue";
                    Accounts.shared.createAlertMessage("Error", (error?.localizedDescription)!, self);
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    //  give a message of error
                    print("Errore:\(error.debugDescription)" )
                    Accounts.shared.createAlertMessage("Error", (error?.localizedDescription)!, self);
                    
                }
            })
            
        
        }
    }
    
    @IBAction func signWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn();

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //when the signin complets
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        //if any error stop and print the error
        if error != nil{
            print(error ?? "google error")
            return
        }
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            if let error = error {
                // ...
                return
            }
            // Set the User_Id
            self.appDelegate.uid = (user?.uid)! ;
            
            // I see if there is already the google account or not
            self.ref?.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                // If not i create a new one
                if !(snapshot.hasChild(self.appDelegate.uid)){
                    // Create the all Informations that I need
                    let reference = self.ref?.child("Users").child(self.appDelegate.uid);
                    reference?.child("Email").setValue("\(user?.email ?? "NoValue")");
                    reference?.child("Language").setValue("English");
                    reference?.child("Unit of Misure").setValue("Metric");
                    reference?.child("NotifyNews").setValue(true);
                    reference?.child("NotifyChanges").setValue(true);
                    reference?.child("Username").setValue( (user?.displayName)!);
                }
                self.navigationController?.popViewController(animated: true);
                
            })

    
            
        }
        
        
        
    }
    
}
