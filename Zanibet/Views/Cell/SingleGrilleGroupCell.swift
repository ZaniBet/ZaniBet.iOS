//
//  SingleGrilleGroupCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 09/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit

class SingleGrilleGroupCell: UITableViewCell {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var fixtureLabel: UILabel!
    @IBOutlet weak var matchDayLabel: UILabel!

    @IBOutlet weak var caption1Label: UILabel!
    @IBOutlet weak var caption2Label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bottomView.layer.cornerRadius = 4
        self.coverImageView.layer.cornerRadius = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
