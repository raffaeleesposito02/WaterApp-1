//
//  MapSegmentedControl.swift
//  WaterApp
//
//  Created by Luigi Previdente on 1/1/18.
//  Copyright © 2018 Raffaele. All rights reserved.
//

import UIKit

class MapSegmentedControl: UISegmentedControl {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        removeBorders();
        setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor(named: "BluOcean")!, NSAttributedStringKey.font:UIFont(name: "Helvetica Neue", size: 15)], for: .selected);
        setTitleTextAttributes([NSAttributedStringKey.font:UIFont(name: "Helvetica Neue", size: 15)], for: .normal);
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = true;
    }
    
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }

}
