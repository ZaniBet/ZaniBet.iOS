//
//  GrilleCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class GrilleCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBOutlet weak var jackpotNameLabel: UILabel!
    
    @IBOutlet weak var caption1Label: UILabel!
    
    @IBOutlet weak var caption2Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
