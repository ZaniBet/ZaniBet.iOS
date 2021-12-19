//
//  PayoutController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import UIEmptyState
import NVActivityIndicatorView
//import MoPub

class PayoutController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    @IBOutlet weak var payoutTableView: UITableView!
    
    var indicatorView:NVActivityIndicatorView!
    var payouts:[Payout] = []

    var networkError:Bool = false
    var internetError:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.flatWhite
        self.title = NSLocalizedString("title_payout_history", comment: "")
        self.payoutTableView.delegate = self
        self.payoutTableView.dataSource = self
        
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        // Optionally remove seperator lines from empty cells
        self.payoutTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: (self.view.bounds.width/2)-25, y: (self.view.bounds.height/2)-89, width: 50, height: 50) )
        self.indicatorView!.type = .ballClipRotateMultiple
        self.indicatorView!.color = .flatGreen
        self.view.addSubview(self.indicatorView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        self.emptyStateView.isHidden = true
        if (self.payouts.count == 0){
            self.indicatorView!.startAnimating()
        }
        self.fetchPayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var emptyStateImage: UIImage? {
        if (networkError || internetError){
            return #imageLiteral(resourceName: "global_error")
        }
        return #imageLiteral(resourceName: "empty_payout")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.flatGray, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 13)!]
        
        if (self.networkError == true){
            return NSAttributedString(string: NSLocalizedString("err_network", comment: ""), attributes: attrs)
        } else if (self.internetError == true){
            return NSAttributedString(string: NSLocalizedString("maintenance_mode", comment: ""), attributes: attrs)
        }
        
        return NSAttributedString(string: NSLocalizedString("empty_payout", comment: ""), attributes: attrs)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.payouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "payoutCell", for: indexPath) as! PayoutCell
        let payout = self.payouts[indexPath.row]
        switch(payout.kind){
        case "Reward":
            cell.dateLabel.text = "\(payout.createdAt!)"
            cell.payoutNameLabel.text = NSLocalizedString("payout_for_reward", comment: "")
            cell.earnLabel.text = "\(payout.amount!)€"
            break
        case "Grille":
            cell.dateLabel.text = "\(payout.createdAt!)"
            //let gameTicket:[String:Any] = payout.target!["gameTicket"] as! [String : Any]
            cell.payoutNameLabel.text = NSLocalizedString("payout_for_grid", comment: "")
            cell.earnLabel.text = "\((payout.amount!))€"
            break
        default:
            break
        }
        
        if let createdDate = Date(fromString: payout.createdAt!, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc){
            cell.dateLabel.text = createdDate.toString(format: .custom("EEE dd MMM yyyy à HH:mm:ss"),timeZone: .local).capitalized
        }
        
        if (payout.status == "waiting_paiement"){
            cell.statusLabel.text = NSLocalizedString("status_waiting_paiement", comment: "")
            cell.iconImageView.image = #imageLiteral(resourceName: "payout_waiting")
        } else if (payout.status == "canceled" || payout.status == "fraud") {
            cell.statusLabel.text = NSLocalizedString("status_cancel", comment: "")
            cell.iconImageView.image = #imageLiteral(resourceName: "payout_cancel")
        } else if (payout.status == "paid"){
            cell.statusLabel.text = NSLocalizedString("stauts_paid", comment: "")
            cell.iconImageView.image = #imageLiteral(resourceName: "payout_done")
        } else {
            cell.statusLabel.text = payout.status
            cell.iconImageView.image = #imageLiteral(resourceName: "payout_waiting")
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func fetchPayout(){
        self.internetError = false
        self.networkError = false
        Alamofire.request(PayoutRouter.getPayouts()).validate().responseArray { (response: DataResponse<[Payout]>) in
            self.indicatorView.stopAnimating()
            switch (response.result){
            case .success:
                self.payouts = response.result.value!
                self.payoutTableView.reloadData()
                self.reloadEmptyStateForTableView(self.payoutTableView)
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
                self.payouts.removeAll()
                self.payoutTableView.reloadData()
                self.reloadEmptyStateForTableView(self.payoutTableView)
            }
        }
    }
    
}

