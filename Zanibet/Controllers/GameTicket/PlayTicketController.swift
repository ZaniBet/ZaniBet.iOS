//
//  PlayTicketController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AFDateHelper
import ChameleonFramework
import SCLAlertView
import Imaginary
import SwiftIcons
import SwiftyJSON
import MoPub

class PlayTicketController: UIViewController, UITableViewDataSource, UITableViewDelegate, BetCellDelegate {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var ticketNameLabel: UILabel!
    @IBOutlet weak var remainingPlayLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    //@IBOutlet weak var jackpotAmountLabel: UILabel!
    
    @IBOutlet weak var matchdayLabel: UILabel!
    @IBOutlet weak var betsTableView: UITableView!
    
    @IBOutlet weak var clearGrilleButton: UIButton!
    @IBOutlet weak var flashGrilleButton: UIButton!
    @IBOutlet weak var validateGrilleButton: UIButton!
    
    @IBOutlet weak var pointRewardLabel: UILabel!
    @IBOutlet weak var cashRewardLabel: UILabel!
    
    
    var gameticket:GameTicket!
    var bets:[String:Int] = [:]
    var adsWatched:Bool = false
    var timer = Timer()
    var timeIsOn = false
    var baseInset:CGFloat = -20
    var adsLoading = false
    var isFlashed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ticket \(self.gameticket.name.replacingOccurrences(of: "Jackpot", with: ""))"
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barTintColor = HexColor("#4CAF50")
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.flatWhite, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 18)!]
        
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        self.betsTableView.dataSource = self
        self.betsTableView.delegate = self
        self.betsTableView.allowsSelection = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(PlayTicketController.popView), name: Notification.Name(rawValue: "popView"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(PlayTicketController.incrementGrillePlay), name: Notification.Name(rawValue: "incrementGrillePlay"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(PlayTicketController.confirmMultiGrid), name: Notification.Name(rawValue: "confirmMultiGrid"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(PlayTicketController.showMultiAdsFail), name: Notification.Name(rawValue: "showMultiAdsFail"), object: nil)

        MPRewardedVideo.loadAd(withAdUnitID: AdsHelper.PLAY_GRID_ID, keywords: nil, userDataKeywords: User.currentUser.id, location: nil, mediationSettings: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < self.baseInset {
            scrollView.contentOffset.y = 0
        }
    }

    
    @objc func popView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func incrementGrillePlay(){
        self.gameticket.numberOfGrillePlay = self.gameticket.numberOfGrillePlay + 1
    }
    
    @objc func confirmMultiGrid(){
        self.adsWatched = true
    }
    
    @objc func showMultiAdsFail(){
        self.validateGrilleButton.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        
        if (HTTPHelper.verifyUrl(urlString: self.gameticket.picture!)){
            let imageUrl = URL(string: self.gameticket.picture!)
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            self.coverImageView.setImage(url: imageUrl!, option: option)
        } else {
            self.coverImageView.image = #imageLiteral(resourceName: "ticket_placeholder")
        }
        
        self.remainingPlayLabel.text = String.localizedStringWithFormat(NSLocalizedString("nb_played_grid", comment: ""), self.gameticket.numberOfGrillePlay!, self.gameticket.maxNumberOfPlay!)

        self.ticketNameLabel.text = self.gameticket.name!.replacingOccurrences(of: " Jackpot", with: "")
        self.matchdayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), self.gameticket.matchday ?? 0)
        //self.jackpotAmountLabel.text = "\(self.gameticket.jackpot!)€"
        self.cashRewardLabel.text = String.localizedStringWithFormat(NSLocalizedString("shared_cash_reward", comment: ""), self.gameticket.jackpot)
        self.pointRewardLabel.text = String.localizedStringWithFormat(NSLocalizedString("point_per_bets", comment: ""), self.gameticket.pointsPerBet, self.gameticket.bonus, self.gameticket.bonusActivation)
        self.clearGrilleButton.backgroundColor = UIColor.flatRed
        self.flashGrilleButton.backgroundColor = UIColor.flatSkyBlue

        self.validateGrilleButton.setIcon(prefixText: "", prefixTextColor: .red, icon: .fontAwesomeSolid(.play),  iconColor: .white, postfixText: NSLocalizedString("validate_grid", comment: ""), postfixTextColor: .white, forState: .normal, textSize: 15, iconSize: 20)
        self.validateGrilleButton.setBackgroundImage(#imageLiteral(resourceName: "green_round_button"), for: .normal)

        self.validateGrilleButton.setIcon(prefixText: "", prefixTextColor: .red, icon: .fontAwesomeSolid(.play),  iconColor: .white, postfixText: NSLocalizedString("loading_video", comment: ""), postfixTextColor: .white, forState: .disabled, textSize: 15, iconSize: 20)
        
        if let limitDate = Date(fromString: gameticket.limitDate!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
            let since = Int(limitDate.since(Date(), in: .second))
            let hour:Int = (since / (60*60));
            let min:Int = ((since / 60) % 60);
            let sec:Int = (since % 60)
            self.remainingTimeLabel.text = String.localizedStringWithFormat(NSLocalizedString("remaining_time", comment: ""), hour, min, sec)
        }
        
        self.flashGrilleButton.layer.cornerRadius = 22
        self.flashGrilleButton.layer.borderWidth = 0
        
        self.clearGrilleButton.layer.cornerRadius = 22
        self.clearGrilleButton.layer.borderWidth = 0
        
        self.validateGrilleButton.isEnabled = false
        if (!timeIsOn){
            timeIsOn = true
            if #available(iOS 10.0, *) {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (time) in
                    if (MPRewardedVideo.hasAdAvailable(forAdUnitID: "4d061f65107f4370a030ba06659982a8")){
                        self.timer.invalidate()
                        self.timeIsOn = false
                        self.validateGrilleButton.isEnabled = true
                    }
                })
            } else {
                // Fallback on earlier versions
                self.timeIsOn = false
                self.validateGrilleButton.isEnabled = true
            }
        }
        
        self.isFlashed = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseInset = 0
        
        if (adsWatched){
            let playTicketConfirmationController = self.storyboard?.instantiateViewController(withIdentifier: "PlayTicketConfirmationController") as! PlayTicketConfirmationController
            playTicketConfirmationController.gameticket = self.gameticket
            self.present(playTicketConfirmationController, animated: true, completion: {
                self.adsWatched = false
                self.bets.removeAll()
                self.betsTableView.reloadData()
                self.betsTableView.setContentOffset(CGPoint.zero, animated: false)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.adsLoading = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.adsLoading = false
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameticket.fixtures.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "betCell", for: indexPath) as! BetCell
        let fixture = self.gameticket.fixtures[indexPath.row]
        
        
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
        
        cell.homeSelection.deselectOtherButtons()
        cell.homeSelection.isSelected = false
        
        if (self.bets[fixture.id!] != nil){
            let selectedBet:Int = self.bets[fixture.id!]!
            switch(selectedBet){
            case 0:
                cell.equalSelection.isSelected = true
                break
            case 1:
                cell.homeSelection.isSelected = true
                break
            case 2:
                cell.awaySelection.isSelected = true
                break
            default:
                break
            }
        }
        
        cell.fixture = fixture
        cell.betCellDelegate = self
        cell.homeTeamLabel.text = fixture.homeTeam.shortName ?? fixture.homeTeam.name
        cell.awayTeamLabel.text = fixture.awayTeam.shortName ?? fixture.awayTeam.name
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func onBetSelected(fixtureId: String, selection: Int) {
        //print("bet selected with id \(fixtureId) and tag \(selection)")
        self.bets.updateValue(selection, forKey: fixtureId)
    }
    
    @IBAction func grilleClearTouched(_ sender: Any) {
        self.isFlashed = false
        self.bets.removeAll()
        self.betsTableView.reloadData()
    }

   
    @IBAction func grilleFlashTouched(_ sender: Any) {
        self.isFlashed = true
        for (fixture) in self.gameticket.fixtures{
            self.bets.updateValue(Int(arc4random_uniform(3)), forKey: fixture.id!)
        }
        self.betsTableView.reloadData()
    }
    
    @IBAction func validateGrilleTouched(_ sender: Any) {
        self.validateGrilleButton.isEnabled = false
        self.tabBarController?.tabBarItem.isEnabled = false
        if (!MPRewardedVideo.hasAdAvailable(forAdUnitID: AdsHelper.PLAY_GRID_ID)){
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_no_ads_available", comment: ""))
            self.validateGrilleButton.isEnabled = true
            return
        }
        
        var betArr:[Bet] = []
        for (fixture, bet) in self.bets {
            betArr.append(Bet(fixtureId: fixture, result: bet))
        }
        
        // Check if all bets is set
        if (betArr.count < self.gameticket.fixtures.count){
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_unfull_grille", comment: ""))
            self.validateGrilleButton.isEnabled = true
            return
        }
        // Check grille limite
        if (self.gameticket.numberOfGrillePlay >= self.gameticket.maxNumberOfPlay){
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_grille_play_reach", comment: ""))
            self.validateGrilleButton.isEnabled = true
            return
        }
        
        convertArrayToDictionaries(bets: betArr)
        //print(allDictionaries)
        adsLoading = true
        
        let params:[String:Any] = ["gameTicket":self.gameticket.id, "bets": allDictionaries, "flashed": self.isFlashed]
        Alamofire.request(GrilleRouter.postGrille(params)).validate().responseJSON {
            response in
            switch (response.result){
            case .success:
                if (self.adsLoading){
                    //DispatchQueue.main.async(execute: {
                    //})
                    MPRewardedVideo.presentAd(forAdUnitID: AdsHelper.PLAY_GRID_ID, from: self, with: nil)
                }
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
                break
            }
        }
    }

    var allDictionaries : [[String : AnyObject]] = [[:]]//array of all dictionaries.
    
    func convertArrayToDictionaries(bets:[Bet]) {
        allDictionaries.removeAll()
        for data in bets {
            let  dictionary = [
                "fixture" : data.fixture,
                "result" : data.result
            ] as [String : Any]
            allDictionaries.append(dictionary as [String : AnyObject])
        }
    }
    
}

