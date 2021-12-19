//
//  ReferralTransactionCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 21/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit

class ReferralTransactionCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var amountView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.usernameView.layer.cornerRadius = 12.0
        self.amountView.layer.cornerRadius = 12.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

