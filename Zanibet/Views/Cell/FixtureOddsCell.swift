//
//  FixtureOddsCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 01/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit

class FixtureOddsCell: UITableViewCell {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var homeTeamImageView: UIImageView!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamImageView: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    
    @IBOutlet weak var homeOddLabel: UILabel!
    @IBOutlet weak var drawOddLabel: UILabel!
    @IBOutlet weak var awayOddLabel: UILabel!
    
    @IBOutlet weak var homeOddView: UIView!
    @IBOutlet weak var drawOddView: UIView!
    @IBOutlet weak var awayOddView: UIView!
    
    @IBOutlet weak var playersHomeOddView: UIView!
    @IBOutlet weak var playersDrawOddView: UIView!
    @IBOutlet weak var playersAwayOddView: UIView!
    
    @IBOutlet weak var playersHomeOddLabel: UILabel!
    @IBOutlet weak var playersDrawOddLabel: UILabel!
    @IBOutlet weak var playersAwayOddLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.borderWidth = 0.4
        self.containerView.layer.borderColor = UIColor.flatWhiteDark.cgColor
        
        self.homeOddView.layer.borderWidth = 0.4
        self.homeOddView.layer.borderColor = UIColor.flatWhiteDark.cgColor
        
        self.drawOddView.layer.borderWidth = 0.4
        self.drawOddView.layer.borderColor = UIColor.flatWhiteDark.cgColor
        
        self.awayOddView.layer.borderWidth = 0.4
        self.awayOddView.layer.borderColor = UIColor.flatWhiteDark.cgColor
        
        self.playersHomeOddView.layer.borderWidth = 0.4
        self.playersHomeOddView.layer.borderColor = UIColor.flatWhiteDark.cgColor
        
        self.playersDrawOddView.layer.borderWidth = 0.4
        self.playersDrawOddView.layer.borderColor = UIColor.flatWhiteDark.cgColor
        
        self.playersAwayOddView.layer.borderWidth = 0.4
        self.playersAwayOddView.layer.borderColor = UIColor.flatWhiteDark.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
