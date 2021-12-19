//
//  GrilleGroupLostCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 28/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class GrilleGroupLostCell: UITableViewCell {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var matchdayLabel: UILabel!
    @IBOutlet weak var gridPlayLabel: UILabel!
    @IBOutlet weak var pronoWinLabel: UILabel!
    @IBOutlet weak var pronoLostLabel: UILabel!
    @IBOutlet weak var zanicoinLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
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


