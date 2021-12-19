//
//  RoundedButton.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 29/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.flatWhite.cgColor
        self.backgroundColor = UIColor.clear
    }

}
