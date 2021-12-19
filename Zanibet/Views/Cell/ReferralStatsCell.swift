//
//  ReferralStatsCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 21/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit

class ReferralStatsCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
