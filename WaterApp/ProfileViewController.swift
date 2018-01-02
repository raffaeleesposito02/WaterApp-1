//
//  ProfileViewController.swift
//  WaterApp
//
//  Created by Alessio Antonisio on 08/12/2017.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var notifyNews: UISwitch!
    @IBOutlet weak var switchNotifyChanges: UISwitch!
    @IBOutlet weak var labelLanguage: UILabel!
    
    @IBOutlet weak var pickerWithButton: UIView!
    @IBOutlet weak var pickerLanguage: UIPickerView!
    @IBOutlet weak var bntDonePicker: UIButton!
    @IBOutlet weak var overlayView: UIView!
    

    @IBOutlet weak var constraintScroll: NSLayoutConstraint!
    
    var localityTable = Array<Array<String>>();
    
    var data = ["Italian", "English"];
    var deleteFavouriteIndexPath: IndexPath?;
    
    var gradientLayer: CAGradientLayer?;
    var pickerSelected : String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // I delegate the picker to itself. Same for the datasource of the picker
        pickerLanguage.delegate = self
        pickerLanguage.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap(gestureReconizer:)))
        labelLanguage.addGestureRecognizer(tap)
        labelLanguage.isUserInteractionEnabled = true;
        gradientToView(view: pickerWithButton);
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        constraintScroll.constant = self.view.frame.width - (292);
        gradientLayer!.frame = self.pickerWithButton.layer.bounds
    }
    
    // Create a gradient view
    func gradientToView(view : UIView) {
        
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame.size = view.frame.size
        gradientLayer!.colors = [UIColor(named: "BluOcean")?.cgColor, UIColor(named:"DarkBlu")?.cgColor]
        gradientLayer!.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradientLayer!, at: 0);
        
    }
    
    @IBAction func donePicker(_ sender: Any) {
        pickerWithButton.isHidden = true;
        overlayView.isHidden = true;
        labelLanguage.text = pickerSelected ?? "\(labelLanguage.text!)";
        labelLanguage.sizeToFit();
        
        if pickerSelected == "English" {
            self.changeToLanguage("en")
        } else {
            self.changeToLanguage("it")
        }
    }
    
    override func  didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func changeToLanguage(_ langCode: String) {
        if Bundle.main.preferredLocalizations.first != langCode {
            let confirmAlert = UIAlertController(title: NSLocalizedString("restartTitle", comment: ""), message: NSLocalizedString("restart", comment: ""), preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: NSLocalizedString("close", comment: ""), style: .destructive) {
                _ in
                UserDefaults.standard.set([langCode], forKey: "AppleLanguages")
                UserDefaults.standard.synchronize()
                exit(EXIT_SUCCESS)
            }
            confirmAlert.addAction(confirmAction)
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            confirmAlert.addAction(cancelAction)
            
            present(confirmAlert, animated: true, completion: nil)
        }
    }
    
    
    @objc func tap(gestureReconizer: UITapGestureRecognizer){
        pickerWithButton.isHidden = false;
        overlayView.isHidden = false;
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelected = data[row]
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = data[row]
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
    }
    

    override func viewWillAppear(_ animated: Bool){
        super.viewDidAppear(animated);
    }
    
    @IBAction func actionNotifyNews(_ sender: Any) {
        // Implement notifications
    }
    
    @IBAction func actionNotifyChanges(_ sender: Any) {
        // Implement notifications
    }
    
}

