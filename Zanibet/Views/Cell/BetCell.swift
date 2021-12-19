//
//  BetCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import DLRadioButton

class BetCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var homeTeamImageView: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var awayTeamImageView: UIImageView!
    
    @IBOutlet weak var homeSelection: DLRadioButton!
    @IBOutlet weak var equalSelection: DLRadioButton!
    @IBOutlet weak var awaySelection: DLRadioButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var betCellDelegate:BetCellDelegate?
    var fixture:Fixture!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.containerView.layer.cornerRadius = 4
        self.containerView.elevate(elevation: 4)
        self.homeSelection.isMultipleSelectionEnabled = false
        
        self.homeSelection.backgroundColor = UIColor.clear
        self.equalSelection.backgroundColor = UIColor.clear
        self.awaySelection.backgroundColor = UIColor.clear

        
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
