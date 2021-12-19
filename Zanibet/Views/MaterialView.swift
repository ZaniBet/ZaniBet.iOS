//
//  MaterialView.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 24/08/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation
import UIKit

protocol MaterialView {
    func elevate(elevation: Double)
}

extension UIView: MaterialView {
    func elevate(elevation: Double){
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.flatGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: elevation)
        self.layer.shadowRadius = CGFloat(elevation)
        self.layer.shadowOpacity = 0.24
    }
}
