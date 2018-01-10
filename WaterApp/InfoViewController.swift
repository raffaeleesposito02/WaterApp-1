//
//  InfoViewController.swift
//  WaterApp
//
//  Created by Raffaele on 08/01/18.
//  Copyright © 2018 Raffaele. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    

    @IBOutlet weak var infoContentTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = Information.shared.infoTitle
        infoContentTextView.text! = Information.shared.infoContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
