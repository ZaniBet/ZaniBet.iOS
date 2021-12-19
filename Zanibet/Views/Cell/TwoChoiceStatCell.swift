//
//  TwoChoiceStatCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 16/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit

class TwoChoiceStatCell: UITableViewCell {

    @IBOutlet weak var choiceOneView: UIView!
    @IBOutlet weak var choiceOneIndicationLabel: UILabel!
    @IBOutlet weak var choiceOneLabel: UILabel!
    
    @IBOutlet weak var choiceTwoView: UIView!
    @IBOutlet weak var choiceTwoIndicatonLabel: UILabel!
    @IBOutlet weak var choiceTwoLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
