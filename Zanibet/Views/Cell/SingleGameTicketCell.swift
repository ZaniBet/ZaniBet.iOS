//
//  SingleGameTicketCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 31/01/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit

class SingleGameTicketCell: UITableViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var competitionImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fixtureLabel: UILabel!
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var competitionView: UIView!
    @IBOutlet weak var indicatorImageView: UIImageView!
    
    @IBOutlet weak var rewardCoinLabel: UILabel!
    
    //@IBOutlet weak var innerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.elevate(elevation: 4)
        self.containerView.layer.cornerRadius = 4
        self.competitionView.layer.cornerRadius = 12
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

