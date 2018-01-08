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

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var notifyNews: UISwitch!
    @IBOutlet weak var switchNotifyChanges: UISwitch!
    @IBOutlet weak var labelLanguage: UILabel!
    
    @IBOutlet weak var pickerWithButton: UIView!
    @IBOutlet weak var pickerLanguage: UIPickerView!
    @IBOutlet weak var bntDonePicker: UIButton!
    @IBOutlet weak var overlayView: UIView!
    
    @IBOutlet weak var developerInfoTableView: UITableView!
    @IBOutlet weak var constraintScroll: NSLayoutConstraint!
    
    var localityTable = Array<Array<String>>();
    
    var data = ["Italian", "English"];
    var deleteFavouriteIndexPath: IndexPath?;
    
    var gradientLayer: CAGradientLayer?;
    var pickerSelected : String?;
    
    //INFO TITLE ARRAY
    var tableInfo: [String] = ["Chi siamo", "Intestinal enterococci", "Escherichia coli"]
    
    //INFO CONTENT ARRAY. WILL BE SHOWN IN INFOVIEWCONTROLLER, WHEN YOU CLICK ON "TABLEINFO" ELEMENT
    var tableContent: [String] = [
        "Luigi Previdente:  Computing science degree, coordinator\n\n\nVincenzo Pugliese : Computing science degree, collaborator\n\n\nAlessio Antonisio: Computing science student, coder\n\n\nRaffaele Esposito: Computing science student, coder\n\n\nVittorio Cimmino: Computing science student, designer\n\n\nGrazia Assunta Mazzei: Computing science student, coder\n\n\nHieda Adriana Silva: PhD Student in Information Engineering, collaborator",
        
        "Enterococci are facultative anaerobic organisms, i.e., they are capable of cellular respiration in both oxygen-rich and oxygen-poor environments. Though they are not capable of forming spores, enterococci are tolerant of a wide range of environmental conditions: extreme temperature (10–45 °C), pH (4.5–10.0), and high sodium chloride concentrations.Enterococci often occur in pairs (diplococci) or short chains. Important clinical infections caused by Enterococcus include urinary tract infections, bacteremia, bacterial endocarditis, diverticulitis, and meningitis. In bodies of water, the acceptable level of contamination is very low. The treshold limit is however established at 200 millions of Unities forming a colony (UFC), for 100 ml of water.",
        
        "Is a common bacterium, genre Enterobacteria, Gram-negative . We can distinguish about 171 serotype. It is normally present in the intestine of all humans and mammals. The are necessary for the correct digestion of the food.. There can be situation in which E. coli can provoke sickness and other disturbance on the man. Example intestinal and urinary infections, meningitis, peritonitis,  septicemy and pneumonia. This happens however rarely and expecially in elevated doses, through alimentar infection rather than in polluted water (when we make a bath) and only by particular subspecies of that (serotype). In particular we are interested in the threshold of it that indicates that coast waters are or less polluted by human activities , sewage discharge. An absence of E.Coli indicates that water is pure, not polluted at all. The treshold limit is however established at 500 millions of Unities forming a colony (UFC), for 100 ml of water"
    ]
    
    @IBOutlet weak var labelTest: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        developerInfoTableView.delegate = self
        developerInfoTableView.dataSource = self
       
        // to show the current language in the labelLanguage
        if labelTest.text == "Language" {
            labelLanguage.text = data[1]
        } else {
            labelLanguage.text = data[0]
        }
        
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
    
    //MANAGE INFO TABLEVIEW ------------------------------------------------------------ BEGIN
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tableInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "developerInfoTableCell", for: indexPath);
        cell.textLabel?.text = tableInfo[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        Information.shared.infoTitle = tableInfo[indexPath.row]
        Information.shared.infoContent = tableContent[indexPath.row]
        
    }
    
    //MANAGE INFO TABLEVIEW ------------------------------------------------------- END
    
}

