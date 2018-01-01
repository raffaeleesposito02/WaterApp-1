//
//  FavoritePlacesView.swift
//  WaterApp
//
//  Created by Luigi Previdente on 1/2/18.
//  Copyright © 2018 Raffaele. All rights reserved.
//

import UIKit

class FavoritePlacesView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "BluOcean")?.cgColor, UIColor(named:"DarkBlu")?.cgColor];
        gradientLayer.locations = [0.0, 1.0];
        gradientLayer.frame.size = self.frame.size
        backgroundColor = UIColor.clear
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
