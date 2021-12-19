//
//  BetPlayedCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 22/04/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import DLRadioButton

class BetPlayedCell: UITableViewCell {
    
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var homeTeamImageView: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var awayTeamImageView: UIImageView!
    
    @IBOutlet weak var homeSelection: DLRadioButton!
    @IBOutlet weak var equalSelection: DLRadioButton!
    @IBOutlet weak var awaySelection: DLRadioButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var betPlayedLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var betCellDelegate:BetCellDelegate?
    var fixture:Fixture!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        homeSelection.isMultipleSelectionEnabled = false
        
        homeSelection.backgroundColor = UIColor.clear
        equalSelection.backgroundColor = UIColor.clear
        awaySelection.backgroundColor = UIColor.clear
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func betSelected(_ sender: DLRadioButton) {
        if (betCellDelegate != nil){
            self.betCellDelegate?.onBetSelected(fixtureId: self.fixture.id!, selection:sender.tag )
        }
    }
}

