//
//  GrilleDetailController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import AFDateHelper
import ChameleonFramework
import Imaginary
//import MoPub
import GoogleMobileAds

class GrilleDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var ticketNameLabel: UILabel!
    @IBOutlet weak var remainingPlayLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var jackpotAmountLabel: UILabel!
    @IBOutlet weak var betsTableView: UITableView!
    @IBOutlet weak var matchDayLabel: UILabel!
    
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var updateDateLabel: UILabel!
    @IBOutlet weak var gridHelpLabel: UILabel!
    
    
    var grille:Grille!
    var baseInset:CGFloat = -20
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gridName:String = self.grille.gameTicket.name.replacingOccurrences(of: "Jackpot", with: "")
        self.title = String.localizedStringWithFormat(NSLocalizedString("title_grid", comment: ""), gridName)
        
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite
        
        self.betsTableView.dataSource = self
        self.betsTableView.delegate = self
        self.betsTableView.allowsSelection = false
        
        // Optionally remove seperator lines from empty cells
        //self.betsTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if (HTTPHelper.verifyUrl(urlString: self.grille.gameTicket.picture!)){
            let imageUrl = URL(string: self.grille.gameTicket.picture!)
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            self.coverImageView.setImage(url: imageUrl!, option: option)
        } else {
            self.coverImageView.image = #imageLiteral(resourceName: "ticket_placeholder")
        }
        
        self.remainingPlayLabel.text = String.localizedStringWithFormat(NSLocalizedString("nb_played_grid", comment: ""), self.grille.gameTicket.numberOfGrillePlay!,self.grille.gameTicket.maxNumberOfPlay!)
        
        self.ticketNameLabel.text = self.grille.gameTicket.name!.replacingOccurrences(of: " Jackpot", with: "")
        self.jackpotAmountLabel.text = "\(self.grille.gameTicket.jackpot!)€"
        if (self.grille.status == "waiting_result"){
            if let resultDate = Date(fromString: self.grille.gameTicket.resultDate!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
                self.remainingTimeLabel.text = String.localizedStringWithFormat(NSLocalizedString("result_at", comment: ""), resultDate.toString(format: .custom("EEE dd MMM yyyy HH:mm:ss"), timeZone: .local))
                
            }
        } else if (self.grille.status == "loose"){
            self.remainingTimeLabel.text = String.localizedStringWithFormat(NSLocalizedString("nb_prono_win", comment: ""), self.grille.numberOfBetsWin!, self.grille.gameTicket.fixtures.count)
            
        } else if (self.grille.status == "win"){
            self.jackpotAmountLabel.text = "\(self.grille.payoutAmount!)€"
            self.remainingTimeLabel.text = NSLocalizedString("jackpot_earn", comment: "")
        }
        
        self.matchDayLabel.text = String.localizedStringWithFormat(NSLocalizedString("n_match_day", comment: ""), self.grille.gameTicket.matchday!)
        
        self.gridHelpLabel.text = NSLocalizedString("grid_details_help", comment: "")
        self.updateGridData()
        
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
        self.bannerView.adUnitID = "ca-app-pub-1821217367102526/6370148338"
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseInset = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        //print("display footer")
    }
    
    func updateGridData(){
        self.referenceLabel.text = String.localizedStringWithFormat(NSLocalizedString("grid_reference", comment: ""), self.grille.reference)
        
        if let createdAt = Date(fromString: self.grille.createdAt, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
            self.createDateLabel.text = String.localizedStringWithFormat(NSLocalizedString("created_at", comment: ""), createdAt.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local))
        } else {
            self.createDateLabel.text = ""
        }
        
        if let updatedAt =  Date(fromString: self.grille.updatedAt, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
            self.updateDateLabel.text = String.localizedStringWithFormat(NSLocalizedString("updated_at", comment: ""), updatedAt.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local))
        } else {
            self.updateDateLabel.text = ""
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < self.baseInset {
            scrollView.contentOffset.y = 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.grille.bets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "betPlayedCell", for: indexPath) as! BetPlayedCell
        let gameticket = self.grille.gameTicket!
        let fixture = gameticket.fixtures[indexPath.row]
        let bets = self.grille.bets;
        
        if (HTTPHelper.verifyUrl(urlString: fixture.homeTeam.logo)){
            let imageUrl = URL(string: fixture.homeTeam.logo!)
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            cell.homeTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            cell.homeTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        if (HTTPHelper.verifyUrl(urlString: fixture.awayTeam.logo)){
            let imageUrl = URL(string: fixture.awayTeam.logo!)
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            cell.awayTeamImageView.setImage(url: imageUrl!, option: option)
        } else {
            cell.awayTeamImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        for bet in bets! {
            if (bet.fixture == fixture.id){
                // Sélectionner le pronostic joué pour le match
                switch(bet.result){
                case 0:
                    cell.betPlayedLabel.text = String.localizedStringWithFormat(NSLocalizedString("played_bet", comment: ""), "N")
                    cell.equalSelection.isSelected = true
                    cell.equalSelection.isEnabled = true
                    
                    cell.homeSelection.isEnabled = false
                    cell.awaySelection.isEnabled = false
                    if (fixture.winner != 0 && self.grille.status == "loose"){
                        cell.equalSelection.iconSelected = #imageLiteral(resourceName: "betn_bad")
                        cell.statusLabel.text = NSLocalizedString("bet_status_loose", comment: "")
                    } else if (fixture.winner == bet.result && self.grille.status != "waiting_result"){
                        cell.statusLabel.text = NSLocalizedString("bet_status_win", comment: "")
                    }
                    break
                case 1:
                    cell.betPlayedLabel.text = String.localizedStringWithFormat(NSLocalizedString("played_bet", comment: ""), "1")
                    cell.homeSelection.isSelected = true
                    cell.homeSelection.isEnabled = true
                    
                    cell.equalSelection.isEnabled = false
                    cell.awaySelection.isEnabled = false
                    if (fixture.winner != 1 && self.grille.status == "loose"){
                        cell.homeSelection.iconSelected = #imageLiteral(resourceName: "bet1_bad")
                        cell.statusLabel.text = NSLocalizedString("bet_status_loose", comment: "")
                    } else if (fixture.winner == bet.result && self.grille.status != "waiting_result"){
                        cell.statusLabel.text = NSLocalizedString("bet_status_win", comment: "")
                    }
                    break
                case 2:
                    cell.betPlayedLabel.text = String.localizedStringWithFormat(NSLocalizedString("played_bet", comment: ""), "2")
                    cell.awaySelection.isSelected = true
                    cell.awaySelection.isEnabled = true
                    
                    cell.equalSelection.isEnabled = false
                    cell.homeSelection.isEnabled = false
                    if (fixture.winner != 2 && self.grille.status == "loose"){
                        cell.awaySelection.iconSelected = #imageLiteral(resourceName: "bet2_bad")
                        cell.statusLabel.text = NSLocalizedString("bet_status_loose", comment: "")
                    } else if (fixture.winner == bet.result && self.grille.status != "waiting_result"){
                        cell.statusLabel.text = NSLocalizedString("bet_status_win", comment: "")
                    }
                    break
                default:
                    break
                }
                
                // Définir le résultat gagnant pour le match
                if (self.grille.status == "loose"){
                    cell.scoreLabel.text = String.localizedStringWithFormat(NSLocalizedString("fixture_score", comment: ""), fixture.homeScore ?? -1, fixture.awayScore ?? -1)
                    /*switch(fixture.winner!){
                    case 0:
                        if (bet.result == 0){
                            cell.statusLabel.text = NSLocalizedString("bet_status_win", comment: "")
                            cell.equalSelection.icon = #imageLiteral(resourceName: "betn_on")
                        } else {
                            cell.equalSelection.icon = #imageLiteral(resourceName: "betn_win")
                        }
                        break
                    case 1:
                        if (bet.result == 1){
                            cell.statusLabel.text = NSLocalizedString("bet_status_win", comment: "")
                            cell.homeSelection.icon = #imageLiteral(resourceName: "bet1_on")
                        } else {
                            cell.homeSelection.icon = #imageLiteral(resourceName: "bet1_win")
                        }
                        break
                    case 2:
                        if (bet.result == 2){
                            cell.statusLabel.text = NSLocalizedString("bet_status_win", comment: "")
                            cell.awaySelection.icon = #imageLiteral(resourceName: "bet2_on")
                        } else {
                            cell.awaySelection.icon = #imageLiteral(resourceName: "bet2_win")
                        }
                        break
                    default:
                        break
                    }*/
                } else if (self.grille.status == "win"){
                    cell.scoreLabel.text = String.localizedStringWithFormat(NSLocalizedString("fixture_score", comment: ""), fixture.homeScore ?? -1, fixture.awayScore ?? -1)
                    cell.statusLabel.text = NSLocalizedString("bet_status_win", comment: "")
                } else if (self.grille.status == "waiting_result"){
                    cell.scoreLabel.text = "VS"
                    cell.statusLabel.text = NSLocalizedString("bet_status_unavailable", comment: "")
                }
            }
        }
        
        
        cell.fixture = fixture
        cell.homeTeamLabel.text = fixture.homeTeam.shortName ?? fixture.homeTeam.name
        cell.awayTeamLabel.text = fixture.awayTeam.shortName ?? fixture.awayTeam.name
        return cell;
    }
    
}
