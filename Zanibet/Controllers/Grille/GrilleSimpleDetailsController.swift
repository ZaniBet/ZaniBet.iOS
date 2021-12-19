//
//  GrilleSimpleDetailsController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 12/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import Imaginary
import Alamofire
import SCLAlertView
//import MoPub
import GoogleMobileAds

class GrilleSimpleDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playedBetsTableView: UITableView!
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var matchDayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var homeTeamImageView: UIImageView!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var awayTeamImageView: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var resultDateLabel: UILabel!
    
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var gridHelpLabel: UILabel!
    
    var gameticket:GameTicket!
    var grille:Grille?
    var fixture:Fixture!
    var baseInset:CGFloat = -20
    var bannerView: GADBannerView!

    let defaultDialogAppearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fixture = gameticket.fixtures[0]
        
        let homeTeamName:String = self.fixture.homeTeam.shortName ?? self.fixture.homeTeam.name
        let awayTeamName:String = self.fixture.awayTeam.shortName ?? self.fixture.awayTeam.name
        self.title = "\(homeTeamName) - \(awayTeamName)"
        
        // Do any additional setup after loading the view.
        self.playedBetsTableView.delegate = self
        self.playedBetsTableView.dataSource = self
        self.playedBetsTableView.allowsSelection = false
        
        if let competition = self.fixture.competition {
            self.competitionLabel.text = competition.name.uppercased() + " - " + competition.country.uppercased()
        } else if let competition = self.gameticket.competition {
            self.competitionLabel.text = competition.name.uppercased() + " - " + competition.country.uppercased()
        } else {
            self.competitionLabel.text = ""
        }
        
        self.matchDayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), self.gameticket.matchday ?? 0).capitalized
        
        if let date =  Date(fromString: fixture.date!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
            self.dateLabel.text = date.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local).uppercased()
        } else {
            self.dateLabel.text = ""
        }
        
        if let resultDate =  Date(fromString: self.gameticket.resultDate!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
            self.resultDateLabel.text = String.localizedStringWithFormat(NSLocalizedString("ticket_result_available_at", comment: ""), resultDate.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local))
        } else {
            self.resultDateLabel.text = ""
        }
        
        self.homeTeamLabel.text = homeTeamName
        self.awayTeamLabel.text = awayTeamName
        
        if (HTTPHelper.verifyUrl(urlString: self.fixture.homeTeam.logo)){
            let imageUrl = URL(string: self.fixture.homeTeam.logo ?? "")
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            self.homeTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            self.homeTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        if (HTTPHelper.verifyUrl(urlString: self.fixture.awayTeam.logo)){
            let imageUrl = URL(string: self.fixture.awayTeam.logo ?? "")
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            self.awayTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            self.awayTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        self.scoreLabel.text = "\(self.fixture.homeScore ?? 0) : \(self.fixture.awayScore ?? 0)"
        self.rewardLabel.text = String.localizedStringWithFormat(NSLocalizedString("reward_per_bet", comment: ""), self.gameticket.pointsPerBet, self.gameticket.bonus)
        self.gridHelpLabel.text = NSLocalizedString("grid_details_help", comment: "")
        self.updateGridData()
        
        if (self.grille == nil){
            Alamofire.request(GrilleRouter.getSinglePlayedGrille(self.gameticket.id))
                .responseObject(completionHandler: { (response: DataResponse<Grille>) in
                    switch (response.result){
                    case .success(let grille):
                        self.grille = grille
                        self.updateGridData()
                        self.playedBetsTableView.reloadData()
                        break
                    case .failure(let error):
                        if let err = error as? URLError
                        {
                            if (err.code == URLError.Code.notConnectedToInternet){
                                // No internet
                                //self.internetError = true
                            } else {
                                // Serveur indisponible
                                //self.networkError = true
                            }
                        } else {
                            // Other errors
                            //self.networkError = true
                        }
                    }
                })
        }
        
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        self.bannerView.adUnitID = "ca-app-pub-1821217367102526/2232426926"
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseInset = 0
    }
    
    func updateGridData(){
        if let grid = self.grille{
            if (grid.status != "waiting_result"){
                self.rewardLabel.text = String.localizedStringWithFormat(NSLocalizedString("amount_zanicoins", comment: ""), self.gameticket.pointsPerBet * grid.numberOfBetsWin!)
                self.resultDateLabel.text = String.localizedStringWithFormat(NSLocalizedString("winning_bets", comment: ""), grid.numberOfBetsWin!, grid.bets.count)
            }
            
            self.referenceLabel.text = String.localizedStringWithFormat(NSLocalizedString("grid_reference", comment: ""), grid.reference)
            
            if let createdAt = Date(fromString: grid.createdAt, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
                self.createDateLabel.text = String.localizedStringWithFormat(NSLocalizedString("created_at", comment: ""), createdAt.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local))
            } else {
                self.createDateLabel.text = ""
            }
            
            if let updatedAt =  Date(fromString: grid.updatedAt, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
                self.updateDateLabel.text = String.localizedStringWithFormat(NSLocalizedString("updated_at", comment: ""), updatedAt.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local))
            } else {
                self.updateDateLabel.text = ""
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < self.baseInset {
            scrollView.contentOffset.y = 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let betsType = self.gameticket.betsType {
            //print(betsType.count)
            return betsType.count * 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if ((section+1) % 2 == 0){
            return NSLocalizedString("players_choices", comment: "")
        }
        
        if let betsType = self.gameticket.betsType {
            var betType:BetType
            if (section == 0){
                betType = betsType[section]
            } else {
                betType = betsType[section/2]
            }
            
            if (betType.type == "1N2"){
                return NSLocalizedString("bet_who_win", comment: "")
            } else if (betType.type == "BOTH_GOAL"){
                return NSLocalizedString("bet_both_goal", comment: "")
            } else if (betType.type == "LESS_MORE_GOAL"){
                return NSLocalizedString("bet_less_more", comment: "")
            } else if (betType.type == "FIRST_GOAL"){
                return NSLocalizedString("bet_first_goal", comment: "")
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //tableView.backgroundColor = UIColor.whiteColor()
        let headerFrame = tableView.frame
        
        let title = UILabel()
        title.frame = CGRect(x: 10, y: 0, width: headerFrame.size.width-20, height: 30)
        title.font = UIFont(name: "Futura", size: 12)!
        title.text = self.tableView(tableView, titleForHeaderInSection: section)
        //title.textColor = UIColor(red: 34/255.0, green: 141/255.0, blue: 183/255.0, alpha: 1.0)
        title.textColor = UIColor.flatBlackDark
        
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.backgroundColor = UIColor.flatWhite
        headerView.addSubview(title)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath.section+1) % 2 == 0){
            return 44.0
        }
        return 68.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ((indexPath.section+1) % 2 == 0){
            if let betsType = self.gameticket?.betsType {
                let betType:BetType = betsType[indexPath.section/2]
                if (betType.type == "1N2"){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "threeChoiceStatCell") as! ThreeChoiceStatCell
                    
                    if let odds:[Odds] = self.fixture.odds {
                        for odd in odds {
                            if (odd.bookmaker == "Players" && odd.type == "1N2"){
                                cell.choiceOneLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.homeTeam ?? "-")
                                cell.choiceTwoLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.draw ?? "-")
                                cell.choiceThreeLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.awayTeam ?? "-")
                            }
                        }
                    }
                    return cell

                } else if (betType.type == "FIRST_GOAL") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "threeChoiceStatCell") as! ThreeChoiceStatCell
                    
                    if let odds:[Odds] = self.fixture.odds {
                        for odd in odds {
                            if (odd.bookmaker == "Players-Single" && odd.type == "FIRST_GOAL"){
                                cell.choiceOneLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.homeTeam ?? "-")
                                cell.choiceTwoLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.draw ?? "-")
                                cell.choiceThreeLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.awayTeam ?? "-")
                            }
                        }
                    }
                    
                    return cell
                } else if (betType.type == "BOTH_GOAL") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twoChoiceStatCell") as! TwoChoiceStatCell
                    cell.choiceOneIndicationLabel.text = NSLocalizedString("yes", comment: "")
                    cell.choiceTwoIndicatonLabel.text = NSLocalizedString("no", comment: "")
                    
                    if let odds:[Odds] = self.fixture.odds {
                        for odd in odds {
                            if (odd.bookmaker == "Players-Single" && odd.type == "BOTH_GOAL"){
                                cell.choiceOneLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.positive ?? "-")
                                cell.choiceTwoLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.negative ?? "-")
                            }
                        }
                    }
                    return cell
                } else if (betType.type == "LESS_MORE_GOAL") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "twoChoiceStatCell") as! TwoChoiceStatCell
                    cell.choiceOneIndicationLabel.text = NSLocalizedString("more", comment: "")
                    cell.choiceTwoIndicatonLabel.text = NSLocalizedString("less", comment: "")
                    
                    if let odds:[Odds] = self.fixture.odds {
                        for odd in odds {
                            if (odd.bookmaker == "Players-Single" && odd.type == "LESS_MORE_GOAL"){
                                cell.choiceOneLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.positive ?? "-")
                                cell.choiceTwoLabel.text = String.localizedStringWithFormat(NSLocalizedString("odd_percent", comment: ""), odd.value?.negative ?? "-")
                            }
                        }
                    }
                    return cell
                }
            }
        }
        
        let fixture = self.gameticket.fixtures[0]
        
        if let betsType = self.gameticket?.betsType {
            var betType:BetType
            if (indexPath.section == 0){
                betType = betsType[indexPath.section]
            } else {
                betType = betsType[indexPath.section/2]
            }
            
            if (betType.type == "LESS_MORE_GOAL"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "twoChoiceBetCell") as! TwoChoiceBetCell
                if let grille = self.grille {
                    for bet in grille.bets {
                        if (bet.type! == "LESS_MORE_GOAL"){
                            switch(bet.result){
                            case 0:
                                cell.choiceTwoRadio.isSelected = true
                                cell.choiceOneRadio.isEnabled = false
                                break
                            case 1:
                                cell.choiceOneRadio.isSelected = true
                                cell.choiceTwoRadio.isEnabled = false
                                break
                            default:
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceTwoRadio.isEnabled = false
                                break
                            }
                        }
                    }
                }
                cell.betType = "LESS_MORE_GOAL"
                cell.choiceOneLabel.text = NSLocalizedString("more_two", comment: "")
                cell.choiceTwoLabel.text = NSLocalizedString("less_two", comment: "")
                return cell
            } else if (betType.type == "BOTH_GOAL"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "twoChoiceBetCell") as! TwoChoiceBetCell
                if let grille = self.grille {
                    for bet in grille.bets {
                        if (bet.type! == "BOTH_GOAL"){
                            switch(bet.result){
                            case 0:
                                cell.choiceTwoRadio.isSelected = true
                                cell.choiceOneRadio.isEnabled = false
                                break
                            case 1:
                                cell.choiceOneRadio.isSelected = true
                                cell.choiceTwoRadio.isEnabled = false
                                break
                            default:
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceTwoRadio.isEnabled = false
                                break
                            }
                        }
                    }
                }
                cell.betType = "BOTH_GOAL"
                cell.choiceOneLabel.text = NSLocalizedString("yes", comment: "")
                cell.choiceTwoLabel.text = NSLocalizedString("no", comment: "")
                return cell
            } else if (betType.type == "1N2"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "threeChoiceBetCell") as! ThreeChoiceBetCell
                if let grille = self.grille {
                    for bet in grille.bets {
                        if (bet.type! == "1N2"){
                            switch(bet.result){
                            case 0:
                                cell.choiceTwoRadio.isEnabled = true
                                cell.choiceTwoRadio.isSelected = true
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceThreeRadio.isEnabled = false
                                break
                            case 1:
                                cell.choiceOneRadio.isEnabled = true
                                cell.choiceOneRadio.isSelected = true
                                cell.choiceTwoRadio.isEnabled = false
                                cell.choiceThreeRadio.isEnabled = false
                                break
                            case 2:
                                cell.choiceThreeRadio.isEnabled = true
                                cell.choiceThreeRadio.isSelected = true
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceTwoRadio.isEnabled = false
                                break
                            default:
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceTwoRadio.isEnabled = false
                                cell.choiceThreeRadio.isEnabled = false
                                break
                            }
                        }
                    }
                }
                cell.betType = "1N2"
                cell.choiceOneLabel.text = fixture.homeTeam.shortName ?? fixture.homeTeam.name
                cell.choiceTwoLabel.text = NSLocalizedString("draw_match", comment: "")
                cell.choiceThreeLabel.text = fixture.awayTeam.shortName ?? fixture.awayTeam.name
                return cell
            } else if (betType.type == "FIRST_GOAL"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "threeChoiceBetCell") as! ThreeChoiceBetCell
                if let grille = self.grille {
                    for bet in grille.bets {
                        if (bet.type! == "FIRST_GOAL"){
                            switch(bet.result){
                            case 0:
                                cell.choiceTwoRadio.isEnabled = true
                                cell.choiceTwoRadio.isSelected = true
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceThreeRadio.isEnabled = false
                                break
                            case 1:
                                cell.choiceOneRadio.isEnabled = true
                                cell.choiceOneRadio.isSelected = true
                                cell.choiceTwoRadio.isEnabled = false
                                cell.choiceThreeRadio.isEnabled = false
                                break
                            case 2:
                                cell.choiceThreeRadio.isEnabled = true
                                cell.choiceThreeRadio.isSelected = true
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceTwoRadio.isEnabled = false
                                break
                            default:
                                cell.choiceOneRadio.isEnabled = false
                                cell.choiceTwoRadio.isEnabled = false
                                cell.choiceThreeRadio.isEnabled = false
                                break
                            }
                        }
                    }
                }
                cell.betType = "FIRST_GOAL"
                cell.choiceOneLabel.text = fixture.homeTeam.shortName ?? fixture.homeTeam.name
                cell.choiceTwoLabel.text = NSLocalizedString("no_goal", comment: "")
                cell.choiceThreeLabel.text = fixture.awayTeam.shortName ?? fixture.awayTeam.name
                return cell
            }
            
        }
        
        return UITableViewCell()
    }

}
