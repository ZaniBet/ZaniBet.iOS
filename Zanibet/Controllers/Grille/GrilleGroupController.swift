//
//  GrilleListController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import AFDateHelper
import UIEmptyState
import NVActivityIndicatorView
import SCLAlertView
import Imaginary
import SwiftyJSON
import ObjectMapper
import KRPullLoader

class GrilleGroupController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate, KRPullLoadViewDelegate {
    
    
    @IBOutlet weak var grilleTableView: UITableView!
    @IBOutlet weak var statusSegment: UISegmentedControl!
    
    var groupGrilles:[GrilleGroup] = []
    var indicatorView:NVActivityIndicatorView!
    var networkError:Bool = false
    var internetError:Bool = false
    var currentStatus:String = ""
    var pages: [String: [String:Int]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grilleTableView.dataSource = self
        self.grilleTableView.delegate = self
        self.grilleTableView.rowHeight = UITableViewAutomaticDimension
        self.grilleTableView.estimatedRowHeight = 280
        
        self.pages["waiting_result"] = ["currentPage": 0, "queryLimit": 5]
        self.pages["loose"] = ["currentPage": 0, "queryLimit": 5]
        self.pages["single"] = ["currentPage": 0, "queryLimit": 5]
        self.pages["win"] = ["currentPage": 0, "queryLimit": 5]

        // Load more & pull to refresh
        let refreshView = KRPullLoadView()
        refreshView.delegate = self
        self.grilleTableView.addPullLoadableView(refreshView, type: .refresh)
        
        let loadMoreView = KRPullLoadView()
        loadMoreView.delegate = self
        self.grilleTableView.addPullLoadableView(loadMoreView, type: .loadMore)
        
        // Set the data source and delegate
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        // Optionally remove seperator lines from empty cells
        self.grilleTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: (self.view.bounds.width/2)-25, y: (self.view.bounds.height/2)-89, width: 50, height: 50) )
        self.indicatorView!.type = .ballClipRotateMultiple
        self.indicatorView!.color = .flatGreen
        self.view.addSubview(self.indicatorView!)
        
        let pendingSingleGrilleNib = UINib(nibName: "PendingSingleGrilleGroupCell", bundle: nil)
        let doneSingleGrilleNib = UINib(nibName: "DoneSingleGrilleGroupCell", bundle: nil)

        self.grilleTableView.register(pendingSingleGrilleNib, forCellReuseIdentifier: "pendingSingleGrilleGroupCell")
        self.grilleTableView.register(doneSingleGrilleNib, forCellReuseIdentifier: "doneSingleGrilleGroupCell")
   
        self.statusSegment.setTitle(NSLocalizedString("segment_pending", comment: ""), forSegmentAt: 0)
        self.statusSegment.setTitle(NSLocalizedString("segment_multi", comment: ""), forSegmentAt: 1)
        self.statusSegment.setTitle(NSLocalizedString("segment_simple", comment: ""), forSegmentAt: 2)
        self.statusSegment.setTitle(NSLocalizedString("segment_jackpot", comment: ""), forSegmentAt: 3)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emptyStateView.isHidden = true
        if (self.groupGrilles.count == 0){
            self.indicatorView!.startAnimating()
            switch statusSegment.selectedSegmentIndex
            {
            case 0:
                self.currentStatus = "waiting_result"
                self.refreshGrilles(completion: nil)
                break
            case 1:
                self.currentStatus = "loose"
                self.refreshGrilles(completion: nil)
                break
            case 2:
                self.currentStatus = "single"
                self.refreshGrilles(completion: nil)
                break
            default:
                self.currentStatus = "win"
                self.refreshGrilles(completion: nil)
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func segmentIndexChanged(_ sender: Any) {
        self.groupGrilles.removeAll()
        self.grilleTableView.reloadData()
        self.emptyStateView.isHidden = true
        self.indicatorView!.startAnimating()
        switch statusSegment.selectedSegmentIndex
        {
        case 0:
            self.pages["waiting_result"] = ["currentPage": 0, "queryLimit": 5]
            self.currentStatus = "waiting_result"
            self.fetchGrilles(completion: nil)
            break
        case 1:
            self.pages["loose"] = ["currentPage": 0, "queryLimit": 5]
            self.currentStatus = "loose"
            self.fetchGrilles(completion: nil)
            break
        case 2:
            self.pages["single"] = ["currentPage": 0, "queryLimit": 5]
            self.currentStatus = "single"
            self.fetchGrilles(completion: nil)
            break
        default:
            self.pages["win"] = ["currentPage": 0, "queryLimit": 5]
            self.currentStatus = "win"
            self.fetchGrilles(completion: nil)
            break
        }
    }
    
    // Pull to refresh & load more delegate
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                self.pages[self.currentStatus]!["currentPage"]! += 1
                //self.currentPage += 1
                self.fetchGrilles {
                    completionHandler()
                }
            default:
                break
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
            self.refreshGrilles {
                completionHandler()
            }
        }
    }
    
    // Empty List Delegate
    var emptyStateImage: UIImage? {
        if (networkError == true || internetError == true){
            return #imageLiteral(resourceName: "global_error")
        }
        
        switch statusSegment.selectedSegmentIndex
        {
        case 0:
            return #imageLiteral(resourceName: "empty_pending_grid")
        case 1:
            return #imageLiteral(resourceName: "empty_multi_grid")
        case 2:
            return #imageLiteral(resourceName: "empty_simple_grid")
        default:
            return #imageLiteral(resourceName: "empty_winning_grid")
        }
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.flatGray, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 13)!]
        
        if (self.networkError == true){
            return NSAttributedString(string: NSLocalizedString("err_network", comment: ""), attributes: attrs)
        } else if (self.internetError == true){
            return NSAttributedString(string: NSLocalizedString("maintenance_mode", comment: ""), attributes: attrs)
        }
        
        switch statusSegment.selectedSegmentIndex
        {
        case 0:
            return NSAttributedString(string: NSLocalizedString("empty_grille_waiting", comment: ""), attributes: attrs)
        case 1:
            return NSAttributedString(string: NSLocalizedString("empty_grille_loose", comment: ""), attributes: attrs)
        case 2:
            return NSAttributedString(string: NSLocalizedString("empty_grille_simple", comment: ""), attributes: attrs)
        default:
            return NSAttributedString(string: NSLocalizedString("empty_grille_win", comment: ""), attributes: attrs)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupGrilles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let grille: Grille = groupGrilles[indexPath.row].grilles[0]
        let gameticket: GameTicket = groupGrilles[indexPath.row].gameticket
        //cell.jackpotNameLabel.text = String.localizedStringWithFormat(NSLocalizedString("ticket_week", comment: ""), grille.gameTicket.name!, grille.gameTicket.matchday!)
        
        if (grille.type == "MULTI"){
            switch(grille.status){
            case "waiting_result":
                let cell = tableView.dequeueReusableCell(withIdentifier: "grilleGroupPendingCell", for: indexPath) as! GrilleGroupPendingCell
                if (HTTPHelper.verifyUrl(urlString: gameticket.picture)){
                    let imageUrl = URL(string: gameticket.picture!)
                    var option = Option()
                    option.storageMaker = {
                        return Configuration.imageStorage
                    }
                    cell.coverImageView.setImage(url: imageUrl!, option:option)
                } else {
                    cell.coverImageView.image = #imageLiteral(resourceName: "ticket_placeholder")
                }
                
                cell.competitionLabel.text = gameticket.name.replacingOccurrences(of: " Jackpot", with: "")
                cell.matchdayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), gameticket.matchday!)
                
                if let resultDate = Date(fromString: gameticket.resultDate!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
                    cell.descriptionLabel.text = String.localizedStringWithFormat(NSLocalizedString("pending_grid_desc", comment: ""), groupGrilles[indexPath.row].grilles.count, gameticket.matchday!, gameticket.name.replacingOccurrences(of: " Jackpot", with: ""), resultDate.toString(format: .custom("EEE dd MMM yyyy HH:mm:ss"), timeZone: .local))
                }
                
                let potentialZanicoin:Int = (gameticket.pointsPerBet*grille.bets.count) * groupGrilles[indexPath.row].grilles.count
                cell.remainingGridLabel.text = String.localizedStringWithFormat(NSLocalizedString("remaining_grille", comment: ""), gameticket.maxNumberOfPlay - groupGrilles[indexPath.row].grilles.count).uppercased()
                cell.zanicoinLabel.text = String.localizedStringWithFormat(NSLocalizedString("amount_zanicoins_group", comment: ""), potentialZanicoin).uppercased()
                cell.cashLabel.text = String.localizedStringWithFormat(NSLocalizedString("grille_paypal", comment: ""), gameticket.jackpot!).uppercased()
                return cell;
            case "loose":
                let cell = tableView.dequeueReusableCell(withIdentifier: "grilleGroupLostCell", for: indexPath) as! GrilleGroupLostCell
                if (HTTPHelper.verifyUrl(urlString: gameticket.picture)){
                    let imageUrl = URL(string: gameticket.picture!)
                    var option = Option()
                    option.storageMaker = {
                        return Configuration.imageStorage
                    }
                    cell.coverImageView.setImage(url: imageUrl!, option:option)
                } else {
                    cell.coverImageView.image = #imageLiteral(resourceName: "ticket_placeholder")
                }
                
                cell.competitionLabel.text = gameticket.name.replacingOccurrences(of: " Jackpot", with: "")
                cell.matchdayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), gameticket.matchday!)
                cell.descriptionLabel.text = String.localizedStringWithFormat(NSLocalizedString("lost_grid_desc", comment: ""), gameticket.matchday!)
                cell.gridPlayLabel.text = String.localizedStringWithFormat(NSLocalizedString("play_grille", comment: ""), groupGrilles[indexPath.row].grilles.count).uppercased()
                
                var pronoWin = 0
                for grille in groupGrilles[indexPath.row].grilles {
                    pronoWin += grille.numberOfBetsWin!
                }
                let zanicoins = pronoWin * grille.gameTicket.pointsPerBet
                let pronoLost = (grille.gameTicket.fixtures.count * groupGrilles[indexPath.row].grilles.count)-pronoWin
                
                cell.pronoWinLabel.text = String.localizedStringWithFormat(NSLocalizedString("pronos_win", comment: ""), pronoWin).uppercased()
                cell.pronoLostLabel.text = String.localizedStringWithFormat(NSLocalizedString("prono_lost", comment: ""), pronoLost).uppercased()
                cell.zanicoinLabel.text = String.localizedStringWithFormat(NSLocalizedString("amount_zanicoins_group", comment: ""), zanicoins).uppercased()
                
                return cell;
            case "win":
                let cell = tableView.dequeueReusableCell(withIdentifier: "grilleGroupWinCell", for: indexPath) as! GrilleGroupWinCell
                if (HTTPHelper.verifyUrl(urlString: gameticket.picture)){
                    let imageUrl = URL(string: gameticket.picture!)
                    var option = Option()
                    option.storageMaker = {
                        return Configuration.imageStorage
                    }
                    cell.coverImageView.setImage(url: imageUrl!, option:option)
                } else {
                    cell.coverImageView.image = #imageLiteral(resourceName: "ticket_placeholder")
                }
                
                cell.competitionLabel.text = gameticket.name.replacingOccurrences(of: " Jackpot", with: "")
                cell.matchdayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), gameticket.matchday!)
                cell.descriptionLabel.text = NSLocalizedString("win_grid_desc", comment: "")
                cell.winGridLabel.text = String.localizedStringWithFormat(NSLocalizedString("win_grille", comment: ""), groupGrilles[indexPath.row].grilles.count).uppercased()
                
                var pronoWin = 0
                for grille in groupGrilles[indexPath.row].grilles {
                    pronoWin += grille.numberOfBetsWin!
                }
                let zanicoins = (pronoWin * grille.gameTicket.pointsPerBet) + (groupGrilles[indexPath.row].grilles.count * 1000)
                
                cell.pronoWinLabel.text = String.localizedStringWithFormat(NSLocalizedString("pronos_win", comment: ""), pronoWin).uppercased()
                cell.cashLabel.text = String.localizedStringWithFormat(NSLocalizedString("grille_paypal_float", comment: ""), grille.payoutAmount!).uppercased()
                cell.zanicoinLabel.text = String.localizedStringWithFormat(NSLocalizedString("amount_zanicoins_group", comment: ""), zanicoins).uppercased()
                
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            switch(grille.status){
            case "waiting_result":
                let cell = tableView.dequeueReusableCell(withIdentifier: "pendingSingleGrilleGroupCell", for: indexPath) as! SingleGrilleGroupCell
                
                cell.caption1Label.text = String.localizedStringWithFormat(NSLocalizedString("amount_zanicoins", comment: ""), gameticket.pointsPerBet * grille.bets.count)
                
                if let resultDate = Date(fromString: gameticket.resultDate!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
                    cell.caption2Label.text = String.localizedStringWithFormat(NSLocalizedString("result_at", comment: ""),  resultDate.toString(format: .custom("EEE dd MMM yyyy HH:mm"), timeZone: .local))
                }
                
                cell.fixtureLabel.text = gameticket.name.uppercased()
                cell.matchDayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), gameticket.matchday ?? 0)
                
                if (HTTPHelper.verifyUrl(urlString: gameticket.picture!)){
                    let imageUrl = URL(string: gameticket.picture!)
                    var option = Option()
                    option.storageMaker = {
                        return Configuration.imageStorage
                    }
                    cell.coverImageView.setImage(url: imageUrl!, option: option)
                } else {
                    cell.coverImageView.image = #imageLiteral(resourceName: "ticket_placeholder")
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "doneSingleGrilleGroupCell", for: indexPath) as! SingleGrilleGroupCell
                
                cell.caption1Label.text = String.localizedStringWithFormat(NSLocalizedString("amount_zanicoins", comment: ""), gameticket.pointsPerBet * grille.bets.count)
                cell.caption2Label.text = String.localizedStringWithFormat(NSLocalizedString("winning_bets", comment: ""), grille.numberOfBetsWin!, grille.bets.count)
                
                cell.fixtureLabel.text = gameticket.name.uppercased()
                cell.matchDayLabel.text = String.localizedStringWithFormat(NSLocalizedString("matchday", comment: ""), gameticket.matchday ?? 0)
                
                if (HTTPHelper.verifyUrl(urlString: gameticket.picture!)){
                    let imageUrl = URL(string: gameticket.picture!)
                    var option = Option()
                    option.storageMaker = {
                        return Configuration.imageStorage
                    }
                    cell.coverImageView.setImage(url: imageUrl!, option: option)
                } else {
                    cell.coverImageView.image = #imageLiteral(resourceName: "ticket_placeholder")
                }
                
                return cell
            }
        }
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.groupGrilles[indexPath.row].grilles[0].type == "SIMPLE"){
            return 230.0
        }
        
        switch(self.groupGrilles[indexPath.row].grilles[0].status){
        case "waiting_result":
            return 280
        default:
            return 260
        }
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let grilles:[Grille] = self.groupGrilles[indexPath.row].grilles
        if (grilles[0].type == "SIMPLE"){
            let grilleStoryboard = UIStoryboard(name: "Grille", bundle: nil)
            let grilleSimpleDetailsController = grilleStoryboard.instantiateViewController(withIdentifier: "GrilleSimpleDetailsController") as! GrilleSimpleDetailsController
            grilleSimpleDetailsController.gameticket = grilles[0].gameTicket
            grilleSimpleDetailsController.grille = grilles[0]
            self.navigationController?.show(grilleSimpleDetailsController, sender: nil)

        } else {
            let grilleListController = self.storyboard?.instantiateViewController(withIdentifier: "GrilleListController") as! GrilleListController
            grilleListController.grilles = grilles
            self.navigationController?.pushViewController(grilleListController, animated: true)
            //self.navigationController?.show(grilleListController, sender: nil)
        }
        
    }
    
    func fetchGrilles(completion: (() -> Void)?){
        self.internetError = false
        self.networkError = false
        let params:[String : Any] = ["status": self.currentStatus, "page": self.pages[self.currentStatus]!["currentPage"]!, "limit": self.pages[self.currentStatus]!["queryLimit"]!]
        
        Alamofire.request(GrilleRouter.getGrilles(params))
            .validate()
            .responseJSON { response in
                self.indicatorView.stopAnimating()
                switch (response.result){
                case .success:
                    if let result = response.result.value {
                        //self.groupGrilles.removeAll()
                        let json = JSON(result)
                        for (_,subJson):(String, JSON) in json {
                            // Do something you want
                            let grilleGroup = GrilleGroup()
                            grilleGroup.gameticket = Mapper<GameTicket>().map(JSONString: subJson[0]["gameTicket"].rawString()!)
                            grilleGroup.grilles = Mapper<Grille>().mapArray(JSONString: subJson.rawString()!)
                            self.groupGrilles.append(grilleGroup)
                        }
                        self.grilleTableView.reloadData()
                        self.reloadEmptyStateForTableView(self.grilleTableView)
                        if (completion != nil){
                            completion!()
                        }
                    } else {
                        self.grilleTableView.reloadData()
                        self.reloadEmptyStateForTableView(self.grilleTableView)
                        if (completion != nil){
                            completion!()
                        }
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
                    self.groupGrilles.removeAll()
                    self.grilleTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.grilleTableView)
                    if (completion != nil){
                        completion!()
                    }
                }
                
        }
    }
    
    // Rafraîchir la liste des groupes de grilles
    func refreshGrilles(completion: (() -> Void)?){
        var refreshLimit:Int = self.pages[self.currentStatus]!["queryLimit"]!
        let refreshPage = 0
        // Dans le cas ou d'autres données ont été chargé, récupérer les datas pour l'ensemble des pages
        if (self.pages[self.currentStatus]!["currentPage"]! > 0){
            refreshLimit = (self.pages[self.currentStatus]!["currentPage"]!+1)*refreshLimit
        }
        
        let params: [String:Any] = [ "page": refreshPage, "limit": refreshLimit, "status": self.currentStatus]
        
        self.indicatorView.startAnimating()
        Alamofire.request(GrilleRouter.getGrilles(params))
            .validate()
            .responseJSON { response in
                self.indicatorView.stopAnimating()
                switch (response.result){
                case .success(let value):
                    self.groupGrilles.removeAll()
                    
                    let json = JSON(value)
                    for (_,subJson):(String, JSON) in json {
                        let grilleGroup = GrilleGroup()
                        grilleGroup.gameticket = Mapper<GameTicket>().map(JSONString: subJson[0]["gameTicket"].rawString()!)
                        grilleGroup.grilles = Mapper<Grille>().mapArray(JSONString: subJson.rawString()!)
                        self.groupGrilles.append(grilleGroup)
                    }
                    
                    self.grilleTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.grilleTableView)
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
                    self.groupGrilles.removeAll()
                    self.grilleTableView.reloadData()
                    self.reloadEmptyStateForTableView(self.grilleTableView)
                    if (completion != nil) {
                        completion!()
                    }
                }
        }
    }
    
}
