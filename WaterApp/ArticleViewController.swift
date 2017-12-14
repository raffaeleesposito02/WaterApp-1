//
//  ArticleViewController.swift
//  WaterApp
//
//  Created by Raffaele on 12/12/17.
//  Copyright © 2017 Raffaele. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    
    @IBOutlet weak var newsTitleLabel: UILabel!
    
    @IBOutlet weak var newsContentTextView: UITextView!
    
    @IBOutlet weak var newsImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        newsTitleLabel.text! = News.article.newsTit
        newsContentTextView.text! = News.article.newsCnt
        newsImageView.image = UIImage(named: News.article.newsImgName)
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
