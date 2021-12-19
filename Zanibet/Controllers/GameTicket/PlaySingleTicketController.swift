//
//  PlaySingleTicketController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 31/01/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AFDateHelper
import ChameleonFramework
import SCLAlertView
import Imaginary
import SwiftIcons
import Default

class PlaySingleTicketController: UIViewController, UITableViewDataSource, UITableViewDelegate, SingleBetCellDelegate {
    
    @IBOutlet weak var competitionLabel: UILabel!
    @IBOutlet weak var matchdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var homeTeamImageView: UIImageView!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var awayTeamImageView: UIImageView!
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var jetonLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var betsTableView: UITableView!
    
    
    var gameticket:GameTicket!
    var bets:[String:Int] = [:]
    var adsWatched:Bool = false
    var baseInset:CGFloat = -20

    let defaultDialogAppearance = SCLAlertView.SCLAppearance(
        showCloseButton: false
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fixture = gameticket.fixtures[0]

        let homeTeamName:String = fixture.homeTeam.shortName ?? fixture.homeTeam.name
        let awayTeamName:String = fixture.awayTeam.shortName ?? fixture.awayTeam.name
        self.title = "\(homeTeamName) - \(awayTeamName)"
        
        // Do any additional setup after loading the view.
        self.betsTableView.delegate = self
        self.betsTableView.dataSource = self
        self.betsTableView.allowsSelection = false
        
        self.playButton.setTitle(NSLocalizedString("validate_bet", comment: ""), for: .normal)
        
        if let competition = self.gameticket.competition {
            self.competitionLabel.text = competition.name.uppercased() + " - " + competition.country.uppercased()
        } else {
            self.competitionLabel.text = ""
        }
        
        self.matchdayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), self.gameticket.matchday ?? 0).capitalized
        
        if let date =  Date(fromString: fixture.date!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
            self.dateLabel.text = date.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local).uppercased()
        } else {
            self.dateLabel.text = ""
        }
        
        self.homeTeamLabel.text = homeTeamName
        self.awayTeamLabel.text = awayTeamName
        
        if (HTTPHelper.verifyUrl(urlString: fixture.homeTeam.logo)){
            let imageUrl = URL(string: fixture.homeTeam.logo ?? "")
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            self.homeTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            self.homeTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        if (HTTPHelper.verifyUrl(urlString: fixture.awayTeam.logo)){
            let imageUrl = URL(string: fixture.awayTeam.logo ?? "")
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            self.awayTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            self.awayTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        self.scoreLabel.text = "\(fixture.homeScore ?? 0) : \(fixture.awayScore ?? 0)"
        self.rewardLabel.text = String.localizedStringWithFormat(NSLocalizedString("reward_per_bet", comment: ""), self.gameticket.pointsPerBet, self.gameticket.bonus)
        self.jetonLabel.text = String.localizedStringWithFormat(NSLocalizedString("bet_cost", comment: ""), self.gameticket.jeton).uppercased()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseInset = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.playButton.layer.cornerRadius = 4
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < self.baseInset {
            scrollView.contentOffset.y = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPlayTouch(_ sender: Any) {
        self.playButton.isEnabled = false
        self.tabBarController?.tabBarItem.isEnabled = false
        
        let alertView = SCLAlertView(appearance: self.defaultDialogAppearance)
        var betArr:[Bet] = []
        for (type, bet) in self.bets {
            betArr.append(Bet(type: type, result: bet))
        }
        
        // Check if all bets is set
        if (betArr.count < self.gameticket.betsType!.count){
            alertView.addButton("OK") {
                //print("Second button tapped")
            }
            alertView.showError("Oups", subTitle: NSLocalizedString("err_unfull_bets", comment: ""))
            self.playButton.isEnabled = true
            return
        }
        // Check grille limite
        if (self.gameticket.numberOfGrillePlay >= self.gameticket.maxNumberOfPlay){
            alertView.addButton("OK") {
                //print("Second button tapped")
            }
            alertView.showError("Oups", subTitle: NSLocalizedString("err_grille_play_reach", comment: ""))
            self.playButton.isEnabled = true
            return
        }
        
        convertArrayToDictionaries(bets: betArr)
        //print(allDictionaries)
        
        let params:[String:Any] = ["gameTicket":self.gameticket.id, "bets": allDictionaries]
        Alamofire.request(GrilleRouter.postSingleGrille(params)).validate().responseJSON {
            response in
            switch (response.result){
            case .success:
                if let settings = PlaySettings.read() {
                    PlaySettings(singleCount: settings.singleCount+1, matchdayCount: settings.matchdayCount)
                    .write()
                }
                
                var resultDate:String = ""
                if let date =  Date(fromString: self.gameticket.resultDate!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
                    resultDate = date.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local).capitalized
                }
                
                alertView.addButton("OK") {
                    //print("Second button tapped")
                    self.navigationController?.popViewController(animated: true)
                }
                
                alertView.showSuccess("Youha!", subTitle: String.localizedStringWithFormat(NSLocalizedString("single_grid_validated", comment: ""), self.gameticket.name, resultDate))
                self.playButton.isEnabled = true
                break
            case .failure(let error):
                if let err = error as? URLError
                {
                    if (err.code == URLError.Code.notConnectedToInternet){
                        // No internet
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("err_network", comment: ""))
                        }
                    } else if (err.code.rawValue == -1004){
                        // Serveur indisponible
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("maintenance_mode", comment: ""))
                        }
                    }
                } else {
                    // Other errors
                    if let data = response.data {
                        let json =  JSON(data)
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError("Oups", subTitle: json["detail"].stringValue)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_internal", comment: ""))
                        }
                    }
                }
                self.playButton.isEnabled = true
                break
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let betsType = self.gameticket.betsType {
            return betsType.count
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
        if let betsType = self.gameticket.betsType {
            let betType:BetType = betsType[section]
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
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fixture = self.gameticket.fixtures[0]
        
        if let betsType = self.gameticket.betsType {
            let betType:BetType = betsType[indexPath.section]
            if (betType.type == "LESS_MORE_GOAL"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "twoChoiceBetCell") as! TwoChoiceBetCell
                cell.betType = "LESS_MORE_GOAL"
                cell.choiceOneLabel.text = NSLocalizedString("more_two", comment: "")
                cell.choiceTwoLabel.text = NSLocalizedString("less_two", comment: "")
                cell.betCellDelegate = self
                return cell
            } else if (betType.type == "BOTH_GOAL"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "twoChoiceBetCell") as! TwoChoiceBetCell
                cell.betType = "BOTH_GOAL"
                cell.choiceOneLabel.text = NSLocalizedString("yes", comment: "")
                cell.choiceTwoLabel.text = NSLocalizedString("no", comment: "")
                cell.betCellDelegate = self
                return cell
            } else if (betType.type == "1N2"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "threeChoiceBetCell") as! ThreeChoiceBetCell
                cell.betType = "1N2"
                cell.choiceOneLabel.text = fixture.homeTeam.shortName ?? fixture.homeTeam.name
                cell.choiceTwoLabel.text = NSLocalizedString("draw_match", comment: "")
                cell.choiceThreeLabel.text = fixture.awayTeam.shortName ?? fixture.awayTeam.name
                cell.betCellDelegate = self
                return cell
            } else if (betType.type == "FIRST_GOAL"){
                let cell = tableView.dequeueReusableCell(withIdentifier: "threeChoiceBetCell") as! ThreeChoiceBetCell
                cell.betType = "FIRST_GOAL"
                cell.choiceOneLabel.text = fixture.homeTeam.shortName ?? fixture.homeTeam.name
                cell.choiceTwoLabel.text = NSLocalizedString("no_goal", comment: "")
                cell.choiceThreeLabel.text = fixture.awayTeam.shortName ?? fixture.awayTeam.name
                cell.betCellDelegate = self
                return cell
            }
            
        }
        
        return UITableViewCell()
    }
    
    func onBetSelected(betType: String, selection: Int) {
        self.bets.updateValue(selection, forKey: betType)
        print(self.bets)
    }
    
    var allDictionaries : [[String : AnyObject]] = [[:]]//array of all dictionaries.
    func convertArrayToDictionaries(bets:[Bet]) {
        allDictionaries.removeAll()
        for data in bets {
            let  dictionary = [
                "type" : data.type ?? "",
                "result" : data.result
                ] as [String : Any]
            allDictionaries.append(dictionary as [String : AnyObject])
        }
    }
    
}
