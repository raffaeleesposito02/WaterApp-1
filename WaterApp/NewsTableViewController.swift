//
//  NewsTableViewController.swift
//  WaterApp
//
//  Created by Raffaele on 12/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    //Retrieve news from something and store them in an array (static, for now)
    let newsTitle = ["Physico-Chemical Parameters", "Chlorophyll_a", "pH", "Turbidity"]
   
    


    
    
    
//    // create attributed string
//    //    let myString = "Swift Attributed String"
//    let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.blue ]
//    let myAttrString = NSAttributedString(string: String(newsTitle[1]), attributes: myAttribute)
    
    // set attributed text on a UILabel
 
    let newsContent = ["This application was proposed to predict Chlorophyla_a, PH and Trans parency focused on estimating the physico-chemical parameters seen on the beach in N aples, Italy, using satellite images and Artificial Intelligence Techniques.", "The  Chlorophyll_a (Chl-a) concentration is commonly used as indicator for eutrophication .Chl-a is a direct indi-cator used to evaluate the ecological state of a water body, such as algal blooms that degrade the water quality in lakes, reservoirs and beach", "The optimum pH range for most aquatic organisms is 6.5–8.5, and the acid andalkalin e death points are around pH 4 and pH 11, respectively.  Most livingorganisms do not tolerate large variations in pH and may die", "Turbidity is an optical determination of water clarity 1. Turbid water will appear cloudy, murky, or otherwise colored, af fecting the physical look of the water. Suspended solids and dissolved colored mater ial reduce water clarity by creating an opaque, hazy or muddy appearance. Turbidity   measurements are often used as an indicator of water quality based on clarity and es timated total suspended solids in water."]
    
    var articleImages: [String] = ["PhisicalChemicaParameters.png", "clorophilla.png", "phWater.png", "turbidity.png"]
    
    /* Relationship example:
        If you click the first row, that has newsTitle[0] as title and newsContent[0] as content,
        The image articleImages[0] will be set in ArticleViewController
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return newsTitle.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsTitleCell", for: indexPath)
        cell.textLabel?.text = newsTitle[indexPath.row]
        cell.detailTextLabel?.text = newsContent[indexPath.row]

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        /*let row = indexPath.row
        print("Row: \(row)")*/

        News.article.newsTit = newsTitle[indexPath.row]
        News.article.newsCnt = newsContent[indexPath.row]
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ArticleView") as! ArticleViewController
        
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }*/
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ArticleView" {
            // Pass the selected object to the new view controller.
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                News.article.newsTit = newsTitle[indexPath.row]
                News.article.newsCnt = newsContent[indexPath.row]
                News.article.newsImgName = articleImages[indexPath.row]
            }
            
            if let vc = segue.destination as UIViewController! {
                
                vc.hidesBottomBarWhenPushed = true
            }
        }
    }
 

}
