//
//  MatchdayGameTicketController.swift
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

class MatchdayGameTicketController: UIViewController, UIEmptyStateDataSource, UIEmptyStateDelegate, UITableViewDelegate, UITableViewDataSource, KRPullLoadViewDelegate {
    
    @IBOutlet weak var ticketTableView: UITableView!
    
    var gametickets:[GameTicket] = []
    var networkError:Bool = false
    var internetError:Bool = false
    var currentPage = 0
    var queryLimit = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ticketTableView.dataSource = self
        self.ticketTableView.delegate = self
        self.ticketTableView.allowsSelection = false
        
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        self.ticketTableView.addPullLoadableView(refreshView, type: .refresh)
        
        let loadMoreView = KRPullLoadView()
        loadMoreView.delegate = self
        self.ticketTableView.addPullLoadableView(loadMoreView, type: .loadMore)
                
        // Set the data source and delegate
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        // Supprimer les séparateurs
        self.ticketTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.networkError = false
        self.internetError = false
        self.emptyStateView.isHidden = true
        
        self.refreshData(completion: nil)
        
        if let token = Messaging.messaging().fcmToken {
            Alamofire.request(UserRouter.putFcmToken(["fcmToken": token])).validate()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                self.currentPage += 1
                self.fetchData(params: [ "page": self.currentPage, "limit": self.queryLimit, "ticketType": "MATCHDAY"], completion: {() -> Void in
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
            self.refreshData( completion: {() -> Void in
                completionHandler()
            })
        }
    }
    
    func refreshData(completion: (() -> Void)?){
        var refreshLimit:Int = self.queryLimit
        let refreshPage = 0
        // Dans le cas ou d'autres données ont été chargé, récupérer les datas pour l'ensemble des pages
        if (self.currentPage > 0){
            refreshLimit = (self.currentPage+1)*refreshLimit
        }
        
        let params: [String:Any] = [ "page": refreshPage, "limit": refreshLimit, "ticketType": "MATCHDAY"]
        
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
    
    func fetchData( params: [String:Any], completion: (() -> Void)?){
        showLoadingView()
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
    
    @objc func playTicket(sender:AnyObject){
        if let tag:Int = sender.tag {
            //let playTicketController = self.storyboard?.instantiateViewController(withIdentifier: "PlayTicketController") as! PlayTicketController
            //playTicketController.gameticket = self.gametickets[tag]
            
            //self.navigationController?.pushViewController(playTicketController, animated: true)
            //self.parentPageboyViewController?.navigationController?.show(playTicketController, sender: nil)
            //self.navigationController?.show(playTicketController, sender: self)
            
            //self.show(playTicketController, sender: nil)
            //self.parentPageboyViewController?.navigationController?.pushViewController(playTicketController, animated: false)
            
            let matchdayTicketPageController:MatchdayTicketPageController = MatchdayTicketPageController()
            matchdayTicketPageController.gameticket = self.gametickets[tag]
            //self.present(matchdayTicketPageController, animated: true, completion: nil)
            //self.show(matchdayTicketPageController, sender: nil)
            matchdayTicketPageController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(matchdayTicketPageController, animated: true)
        }
    }
    
    @objc func showCalendar(sender:AnyObject){
        if let tag:Int = sender.tag {
            let gameTicketCalendarController = self.storyboard?.instantiateViewController(withIdentifier: "GameTicketCalendarController") as! GameTicketCalendarController
            gameTicketCalendarController.gameticket = self.gametickets[tag]
            self.parentPageboyViewController?.navigationController?.pushViewController(gameTicketCalendarController, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gametickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameTicketCell", for: indexPath) as! GameTicketCell
        let gameticket = self.gametickets[indexPath.row]
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(self.playTicket(sender:)), for: .touchUpInside)
        
        cell.calendarButton.tag = indexPath.row
        cell.calendarButton.addTarget(self, action: #selector(self.showCalendar(sender:)), for: .touchUpInside)
        //cell.fixtures = gameticket.fixtures!
        
        // Register topic
        if let competition:[String:String] = gameticket.competition?.toJSON() as? [String : String] {
            Messaging.messaging().subscribe(toTopic: "topic_open_gameticket_" + (competition["_id"] ?? ""))
        }
        
        if (HTTPHelper.verifyUrl(urlString: gameticket.picture!)){
            let imageUrl = URL(string: gameticket.picture!)
            let option = Option()
            /*option.fetcherMaker = {
                return ImageFetcher(downloader: ImageDownloader())
            }*/
            cell.coverImageView.setImage(url: imageUrl!, option: option)
        } else {
            cell.coverImageView.image = UIImage(named: "\(gameticket.cover.lowercased())_ticket_cover")
        }
        
        cell.competitionLabel.text = gameticket.name.replacingOccurrences(of: " Jackpot", with: "")
        cell.matchDayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), gameticket.matchday!)
        cell.countMatchLabel.text = String.localizedStringWithFormat(NSLocalizedString("count_match", comment: ""), gameticket.fixtures.count)
        cell.rewardLabel.text = String.localizedStringWithFormat(NSLocalizedString("ticket_potential_cash", comment: ""), gameticket.jackpot)
        cell.remainingGridLabel.text = String.localizedStringWithFormat(NSLocalizedString("ticket_playable_grid", comment: ""), gameticket.maxNumberOfPlay - gameticket.numberOfGrillePlay)
        cell.playButton.setTitle(NSLocalizedString("play", comment: "").uppercased(), for: .normal)
        
        var startAt:String = ""
        var endAt:String = ""
        
        if let startDate = Date(fromString: gameticket.fixtures[0].date!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
            startAt = startDate.toString(format: .custom("EEE dd MMM HH:mm"), timeZone: .local).uppercased()
        }
        
        if let endDate = Date(fromString: (gameticket.fixtures.last?.date)!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
            endAt = endDate.toString(format: .custom("EEE dd MMM HH:mm"), timeZone: .local).uppercased()
        }
        
        cell.dateRangeLabel.text = String.localizedStringWithFormat(NSLocalizedString("date_range_ticket", comment: ""), startAt, endAt)
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 340
    }
}

