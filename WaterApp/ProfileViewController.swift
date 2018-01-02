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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate {
    
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
//
//    //MANAGE FAVOURITES TABLEVIEW ------------------------------------------------------------ BEGIN
//    func numberOfSections(in tableView: UITableView) -> Int {
//
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return self.localityTable.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteTableCell", for: indexPath);
//        cell.textLabel?.text = localityTable[indexPath.row][0];
//        return cell
//    }
//
//    //THIS FUNCTION MAKES TABLEVIEWROWS EDITABLE
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    //THIS FUNCTION HANDLES SLIDE-TO-LEFT GESTURE ON A ROW
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//            confirmDelete(index: indexPath)
//        }
//    }
//
//    //THIS FUNCTION SHOWS A CONFIRM ALERT BEFORE DELETING A FAVOURITE
//    func confirmDelete(index: IndexPath) {
//        let alert = UIAlertController(title: "Delete Favourite", message: "Are you sure you want to permanently delete \(self.localityTable[index.row][0])?", preferredStyle: .actionSheet)
//
//        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteFavourite)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteFavourite)
//        self.deleteFavouriteIndexPath = index;
//        alert.addAction(deleteAction)
//        alert.addAction(cancelAction)
//
//        // Support display in iPad
//        alert.popoverPresentationController?.sourceView = self.view
//        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
//
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    //IF YOU CLICK "DELETE" ON THE ALERT, THIS FUNCTION WILL BE CALLED
//    func handleDeleteFavourite(alertAction: UIAlertAction!) -> Void {
//        if deleteFavouriteIndexPath != nil {
////            self.favouritesTableView.beginUpdates()
////
////            self.favouritesTableView.deleteRows(at: [self.deleteFavouriteIndexPath!], with: .automatic)
////            deleteFavouriteIndexPath = nil
////            self.favouritesTableView.endUpdates()
//
//        self.ref?.child("Preferences").child(self.appDelegate.uid).child(self.localityTable[(deleteFavouriteIndexPath?.row)!][1]).removeValue();
//        }
//    }
//
//    //IF YOU CLICK "CANCEL" ON THE ALERT, THIS FUNCTION WILL BE CALLED
//    func cancelDeleteFavourite(alertAction: UIAlertAction!) {
//        deleteFavouriteIndexPath = nil
//    }
//
    //MANAGE FAVOURITES TABLEVIEW ------------------------------------------------------- END
    
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

