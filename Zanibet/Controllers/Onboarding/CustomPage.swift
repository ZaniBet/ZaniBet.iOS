//
//  CustomPage.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 05/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import SwiftyOnboard

class CustomPage: SwiftyOnboardPage {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var titleTabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomPage", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
