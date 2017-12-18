//
//  AccountsSingleton.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 12/12/2017.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import Foundation
import UIKit

class Accounts {
    
    static let shared = Accounts()
    
    var credentials: [String: String] = ["alejesse":"root"]
    
    var accountsInfo: [String: String] = ["alejesse":"alessioantonisio@gmail.com"]
    
    var accountsSaved: [String: [String]] = ["alejesse":["Napoli"]]
    
    var currentUser: String = "Username"
    
    var isLogged: Bool = false
    
    //----------v-----LOGIN-----v----------
    
    func isUserRight(username: String) -> Bool {
        
        for user in credentials.keys{
            print("controllo username")
            //            print(user, username)
            if user == username {
                print("username trovato!")
                return true
            }
        }
        return false
    }
    
    private func isPasswordRight(username: String, password: String) -> Bool {
        var found: Bool = false
        for pass in credentials.values{
            print("controllo password")
            //            print(pass, password)
            if pass == password {
                print("password trovata!")
                found = true
            }
        }
        if found {
            let associatedUserIndex = credentials.index(forKey: username)
            if credentials[associatedUserIndex!].value == password {
                print("user e password corretti!")
                return true
            }
        }
        print("user e password NON corretti!")
        return false
    }
    
    func doesAccountExist(username: String, password: String) -> Bool {
        print("controllo se esiste")
        return isUserRight(username: username) && isPasswordRight(username: username, password: password)
    }
    
    func setCurrentUser(user: String){
        currentUser = user
    }
    
    //----------^-----LOGIN-----^----------
    
    
    
    //----------v-----CREATE ACCOUNT-----v----------
    
    func addAccountCredentials(username: String, password: String){
        
        self.credentials[username] = password
        
    }
    
    func addAccountInfo(username: String, email: String){
        
        self.accountsInfo[username] = email
        
    }
    
    func checkFields(username: UITextField, password: UITextField, repassword: UITextField, email: UITextField) -> Bool{
        
        return !username.text!.isEmpty && !password.text!.isEmpty && !repassword.text!.isEmpty && !email.text!.isEmpty
        
    }
    
    func createAlertMessage(_ mTitle:String, _ mMessage: String, _ view: UIViewController) {
        
        let alertMessage = UIAlertController(title: mTitle, message: mMessage, preferredStyle: .alert)
        // Attach an action on alert message
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertMessage.dismiss(animated: true, completion: nil)
        }))
        // Display the alert message
        view.present(alertMessage, animated: true, completion: nil)
    }
    
}

