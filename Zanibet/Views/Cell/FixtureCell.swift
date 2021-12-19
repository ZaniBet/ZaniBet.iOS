//
//  FixtureCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 27/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class FixtureCell: UITableViewCell {
    
    
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var homeTeamImageView: UIImageView!
    @IBOutlet weak var awayTeamImageView: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

