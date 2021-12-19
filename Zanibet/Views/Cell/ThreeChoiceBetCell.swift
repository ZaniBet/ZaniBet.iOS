//
//  ThreeChoiceBetCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 31/01/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import DLRadioButton

class ThreeChoiceBetCell: UITableViewCell {
    
    @IBOutlet weak var choiceOneRadio: DLRadioButton!
    @IBOutlet weak var choiceTwoRadio: DLRadioButton!
    @IBOutlet weak var choiceThreeRadio: DLRadioButton!
    @IBOutlet weak var choiceOneLabel: UILabel!
    @IBOutlet weak var choiceTwoLabel: UILabel!
    @IBOutlet weak var choiceThreeLabel: UILabel!
    
    var betCellDelegate:SingleBetCellDelegate?
    var betType:String!
    
    //@IBOutlet weak var innerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        choiceOneRadio.isMultipleSelectionEnabled = false
        choiceOneRadio.tag = 1
        choiceTwoRadio.tag = 0
        choiceThreeRadio.tag = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func betSelected(_ sender: DLRadioButton) {
        if (betCellDelegate != nil){
            self.betCellDelegate?.onBetSelected(betType: self.betType, selection:sender.tag )
        }
    }
}
