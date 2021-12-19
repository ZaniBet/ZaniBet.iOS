//
//  GrilleCellCompex.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 28/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class GrilleCellComplex: UITableViewCell {
    
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var chipLabel: UILabel!
    @IBOutlet weak var chipView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.chipView.layer.cornerRadius = 15
        self.coverImageView.layer.cornerRadius = 12
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

