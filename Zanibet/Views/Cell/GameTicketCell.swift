//
//  GameTicketCell.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import ExpandableCell

class GameTicketCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var matchDayLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var countMatchLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var remainingGridLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var expandableView: UIView!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var calendarButton: UIButton!
    
    
    
    var isExpanded:Bool = false
    
    //@IBOutlet weak var innerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bottomView.layer.borderWidth = 0.1
        //self.innerView.layer.cornerRadius = 4
        self.bottomView.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bottomView.layer.cornerRadius = 4
        self.coverImageView.layer.cornerRadius = 4
        self.playButton.layer.cornerRadius = 20
        self.calendarButton.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
