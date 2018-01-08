//
//  LaunchScreenViewController.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 04/01/2018.
//  Copyright © 2018 Raffaele. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goToApp()
    }
    
    
    func goToApp() {
        
        performSegue(withIdentifier: "fromLaunchToApp", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
