//
//  SingleGameTicketController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 30/01/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import UIEmptyState
import AFDateHelper
import ChameleonFramework
import SwiftIcons
import Imaginary
import Firebase
import ExpandableCell
import KRPullLoader
import SwiftyJSON
//import MoPub
import SCLAlertView
import GoogleMobileAds

class SingleGameTicketController: UIViewController, UIEmptyStateDataSource, UIEmptyStateDelegate, UITableViewDelegate, UITableViewDataSource, KRPullLoadViewDelegate {
    
    
    @IBOutlet weak var jetonLabel: UILabel!
    @IBOutlet weak var moreJetonButton: UIButton!
    @IBOutlet weak var ticketTableView: UITableView!
    
    var gametickets:[GameTicket] = []
    var networkError:Bool = false
    var internetError:Bool = false
    var currentPage = 0
    var queryLimit = 15
    var currentJeton:Int = 0
    var interstitial: GADInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentJeton = User.currentUser.jeton
        
        self.ticketTableView.dataSource = self
        self.ticketTableView.delegate = self
        self.ticketTableView.allowsSelection = true
        
        self.jetonLabel.text = String.localizedStringWithFormat(NSLocalizedString("remaining_jeton", comment: ""), User.currentUser.jeton)
        
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        self.ticketTableView.addPullLoadableView(refreshView, type: .refresh)
        
        let loadMoreView = KRPullLoadView()
        loadMoreView.delegate = self
        self.ticketTableView.addPullLoadableView(loadMoreView, type: .loadMore)
        
        // Set the data source and delegate
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        // Optionally remove seperator lines from empty cells
        self.ticketTableView.tableFooterView = UIView(frame: CGRect.zero)
        

        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-1821217367102526/3502913042")
        let request = GADRequest()
        self.interstitial.load(request)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshGameTicketList(completion: nil)
        
        self.moreJetonButton.isEnabled = true
        UserService.refreshData {
            self.jetonLabel.text = String.localizedStringWithFormat(NSLocalizedString("remaining_jeton", comment: ""), User.currentUser.jeton)
        }
        
        
        if let settings = PlaySettings.read() {
            if (settings.singleCount == 3){
                PlaySettings(singleCount: 0, matchdayCount: settings.matchdayCount)
                    .write()
            
                if self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                } else {
                    print("Ad wasn't ready")
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.moreJetonButton.layer.cornerRadius = 22
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func moreJetonTouched(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MoreChipsController") as! MoreChipsController
        self.navigationController?.show(viewController, sender: nil)
    }
    
    
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                self.currentPage += 1
                self.fetchData(params: [ "page": self.currentPage, "limit": self.queryLimit, "ticketType": "SINGLE"], completion: {() -> Void in
                    completionHandler()
                })
            default: break
            }
            return
        }
        
        switch state {
        case .none:
            pullLoadView.messageLabel.text = ""
            
        case let .pulling(offset, threshould):
            if offset.y > threshould {
                pullLoadView.messageLabel.text = NSLocalizedString("list_pull_more", comment: "")
            } else {
                pullLoadView.messageLabel.text = NSLocalizedString("list_release", comment: "")
            }
            
        case let .loading(completionHandler):
            pullLoadView.messageLabel.text = NSLocalizedString("list_updating", comment: "")
            self.refreshGameTicketList( completion: {() -> Void in
                completionHandler()
            })
        }
    }
    
    /* Rafraîchir la liste des tickets de jeu */
    func refreshGameTicketList(completion: (() -> Void)?){
        var refreshLimit:Int = self.queryLimit
        let refreshPage = 0
        // Dans le cas ou d'autres données ont été chargé, récupérer les datas pour l'ensemble des pages
        if (self.currentPage > 0){
            refreshLimit = (self.currentPage+1)*refreshLimit
        }
        
        let params: [String:Any] = [ "page": refreshPage, "limit": refreshLimit, "ticketType": "SINGLE"]

        showLoadingView()
        Alamofire.request(GameTicketRouter.getGameTickets(params))
            .validate()
            .responseArray { (response: DataResponse<[GameTicket]>) in
                self.hideLoadingView()
                switch (response.result){
                case .success(let value):
                    self.gametickets.removeAll()
                    self.gametickets.append(contentsOf: value)
                    self.ticketTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.ticketTableView)
                    if (completion != nil) {
                        completion!()
                    }
                case .failure(let error):
                    if let err = error as? URLError
                    {
                        if (err.code == URLError.Code.notConnectedToInternet){
                            // No internet
                            self.internetError = true
                        } else {
                            // Serveur indisponible
                            self.networkError = true
                        }
                    } else {
                        // Other errors
                        self.networkError = true
                    }
                    self.gametickets.removeAll()
                    self.ticketTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.ticketTableView)
                    if (completion != nil) {
                        completion!()
                    }
                }
        }
    }
    
    /* Récupérer la liste des tickets */
    func fetchData( params: [String:Any], completion: (() -> Void)?){
        if (self.gametickets.isEmpty){
            showLoadingView()
        }
        Alamofire.request(GameTicketRouter.getGameTickets(params))
            .validate()
            .responseArray { (response: DataResponse<[GameTicket]>) in
                self.hideLoadingView()
                switch (response.result){
                case .success(let value):
                    self.gametickets.append(contentsOf: value)
                    self.ticketTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.ticketTableView)
                    if (completion != nil) {
                        completion!()
                    }
                case .failure(let error):
                    if let err = error as? URLError
                    {
                        if (err.code == URLError.Code.notConnectedToInternet){
                            // No internet
                            self.internetError = true
                        } else {
                            // Serveur indisponible
                            self.networkError = true
                        }
                    } else {
                        // Other errors
                        self.networkError = true
                    }
                    self.gametickets.removeAll()
                    self.ticketTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.ticketTableView)
                    if (completion != nil) {
                        completion!()
                    }
                }
        }
    }
    
    var emptyStateImage: UIImage? {
        if (networkError == true || internetError == true){
            return #imageLiteral(resourceName: "global_error")
        }
        return #imageLiteral(resourceName: "empty_gameticket")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.flatGray, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 13)!]
        
        if (self.networkError == true){
            return NSAttributedString(string: NSLocalizedString("err_network", comment: ""), attributes: attrs)
        } else if (self.internetError == true){
            return NSAttributedString(string: NSLocalizedString("maintenance_mode", comment: ""), attributes: attrs)
        }
        
        return NSAttributedString(string: NSLocalizedString("empty_gameticket", comment: ""), attributes: attrs)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gametickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleGameTicketCell", for: indexPath) as! SingleGameTicketCell
        let gameticket = self.gametickets[indexPath.row]
        let fixture = gameticket.fixtures[0]
        
        var startAt:String = ""
        
        if let date = Date(fromString: fixture.date!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
            if (date.compare(.isToday)){
                startAt = String.localizedStringWithFormat(NSLocalizedString("date_today", comment: ""), date.toString(format: .custom("HH:mm"), timeZone: .local))
            } else if (date.compare(.isTomorrow)){
                startAt = String.localizedStringWithFormat(NSLocalizedString("date_tomorrow", comment: ""), date.toString(format: .custom("HH:mm"), timeZone: .local))
            } else {
                startAt = date.toString(format: .custom("EEE dd MMM HH:mm"), timeZone: .local).uppercased()
            }
        }
        
        cell.dateLabel.text = startAt
        cell.fixtureLabel.text = (fixture.homeTeam.shortName ?? fixture.homeTeam.name) + " - " + (fixture.awayTeam.shortName ?? fixture.awayTeam.name)
        //cell.jetonLabel.text = String.localizedStringWithFormat(NSLocalizedString("amount_jeton", comment: ""), gameticket.jeton)
        cell.rewardCoinLabel.text = String.localizedStringWithFormat(NSLocalizedString("reward_coin_ticket_single", comment: ""), (gameticket.pointsPerBet*gameticket.betsType!.count)+gameticket.bonus)
        
        if let competition:Competition = gameticket.competition {
            cell.flagImageView.image = UIImage(named: competition.country.lowercased().replacingOccurrences(of: " ", with: "_"))
            cell.competitionLabel.text = competition.name
        }
        
        if (HTTPHelper.verifyUrl(urlString: gameticket.thumbnail)){
            let imageUrl = URL(string: gameticket.thumbnail ?? "")
            var option = Option()
            option.storageMaker = {
                return Configuration.imageStorage
            }
            cell.competitionImageView.setImage(url: imageUrl!, option: option)
        } else {
            cell.competitionImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        
        if (gameticket.numberOfGrillePlay >= gameticket.maxNumberOfPlay){
            cell.indicatorImageView.image = #imageLiteral(resourceName: "checked_circle_green")
        } else {
            cell.indicatorImageView.image = #imageLiteral(resourceName: "uncheck_circle")
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let gameticket = self.gametickets[indexPath.row]
        if (gameticket.numberOfGrillePlay > 0){
            let grilleStoryboard = UIStoryboard(name: "Grille", bundle: nil)
            let grilleSimpleDetailsController = grilleStoryboard.instantiateViewController(withIdentifier: "GrilleSimpleDetailsController") as! GrilleSimpleDetailsController
            grilleSimpleDetailsController.gameticket = gameticket
            self.parentPageboyViewController?.navigationController?.pushViewController(grilleSimpleDetailsController, animated: true)
        } else {
            let playSingleTicketController = self.storyboard?.instantiateViewController(withIdentifier: "PlaySingleTicketController") as! PlaySingleTicketController
            playSingleTicketController.gameticket = gameticket
            self.parentPageboyViewController?.navigationController?.pushViewController(playSingleTicketController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
}
