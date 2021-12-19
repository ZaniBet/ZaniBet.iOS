//
//  GrilleGroupCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 28/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class GrilleGroupPendingCell: UITableViewCell {
    
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var remainingGridLabel: UILabel!
    @IBOutlet weak var zanicoinLabel: UILabel!
    @IBOutlet weak var cashLabel: UILabel!
    @IBOutlet weak var matchdayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bottomView.layer.cornerRadius = 4
        self.coverImageView.layer.cornerRadius = 4
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

