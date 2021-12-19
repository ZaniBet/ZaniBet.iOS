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
//import MoPub
import GoogleMobileAds

class GrilleListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    
    @IBOutlet weak var grilleTableView: UITableView!
    
    var bannerView: GADBannerView!
    var grilles:[Grille]!
    var networkError:Bool = false
    var internetError:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localizedStringWithFormat(NSLocalizedString("grid_matchday", comment: ""), self.grilles.first!.gameTicket.name.replacingOccurrences(of: " Jackpot", with: ""), self.grilles.first!.gameTicket.matchday! )
        
        self.grilleTableView.dataSource = self
        self.grilleTableView.delegate = self
        // Set the data source and delegate
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        // Optionally remove seperator lines from empty cells
        self.grilleTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
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
        
        bannerView.adUnitID = "ca-app-pub-1821217367102526/2620397598"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Appodeal.showAd(.rewardedVideo, rootViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emptyStateView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.grilles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let grille = grilles[indexPath.row]

        switch(grille.status){
        case "waiting_result":
            let cell = tableView.dequeueReusableCell(withIdentifier: "grillePendingCell", for: indexPath) as! GrilleCellComplex
            if let createdAt = Date(fromString: grille.createdAt, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
                cell.chipLabel.text = createdAt.toString(format: .custom("EEE dd MMM yyyy HH:mm:ss"), timeZone: .local)
            }
            cell.competitionLabel.text = String.localizedStringWithFormat(NSLocalizedString("compet_day", comment: ""), grille.gameTicket.name.replacingOccurrences(of: " Jackpot", with: "") ,grille.gameTicket.matchday!)
            cell.descriptionLabel.text = NSLocalizedString("grille_pending_desc", comment: "")
            return cell
        case "loose":
            let cell = tableView.dequeueReusableCell(withIdentifier: "grilleLostCell", for: indexPath) as! GrilleCellComplex
            cell.competitionLabel.text = String.localizedStringWithFormat(NSLocalizedString("compet_day", comment: ""), grille.gameTicket.name.replacingOccurrences(of: " Jackpot", with: ""), grille.gameTicket.matchday!)
            cell.descriptionLabel.text = String.localizedStringWithFormat(NSLocalizedString("grille_lost_desc", comment: ""), grille.numberOfBetsWin!, grille.bets.count)
            cell.chipLabel.text = String.localizedStringWithFormat(NSLocalizedString("amount_zanicoins", comment: ""), grille.payoutPoint!)
            return cell
        case "win":
            let cell = tableView.dequeueReusableCell(withIdentifier: "grilleWinCell", for: indexPath) as! GrilleCellComplex
            cell.competitionLabel.text = String.localizedStringWithFormat(NSLocalizedString("compet_day", comment: ""), grille.gameTicket.name.replacingOccurrences(of: " Jackpot", with: ""), grille.gameTicket.matchday!)
            cell.descriptionLabel.text = NSLocalizedString("win_grid_desc", comment: "")
            cell.chipLabel.text = String.localizedStringWithFormat(NSLocalizedString("amount_float", comment: ""), grille.payoutAmount!)
            return cell
        default:
            return UITableViewCell();
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let grilleStoryboard = UIStoryboard(name: "Grille", bundle: nil)
        let grilleDetailsController = grilleStoryboard.instantiateViewController(withIdentifier: "GrilleDetailsController") as! GrilleDetailsController
        self.grilles[indexPath.row].gameTicket.numberOfGrillePlay = self.grilles.count
        grilleDetailsController.grille = self.grilles[indexPath.row]
        self.navigationController?.show(grilleDetailsController, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117
    }
   
}

