//
//  RewardCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit

class RewardCell: UITableViewCell {

    @IBOutlet weak var rewardNameLabel: UILabel!
    @IBOutlet weak var pointsPriceLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var pointsPriceView: UIView!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.stackView.layer.cornerRadius = 4
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //self.chipView.layer.cornerRadius = 15
        //self.coverImageView.layer.cornerRadius = 12
        self.pointsPriceView.layer.cornerRadius = 14
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
