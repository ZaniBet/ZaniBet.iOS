//
//  InvitedFriendsController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 20/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import UIEmptyState
import AFDateHelper
import SwiftyJSON
import KRProgressHUD

class InvitedFriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var invitedTableView: UITableView!
    
    var transactions:[Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.invitedTableView.dataSource = self
        self.invitedTableView.delegate = self
        
        // Supprimer les séparateurs
        self.invitedTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let emptyNib = UINib(nibName: "EmptyCell", bundle: nil)
        
        self.invitedTableView.register(emptyNib, forCellReuseIdentifier: "emptyCell")
        self.fetchTransactions(completition: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 3
        }
        
        if (self.transactions.count == 0){
            return 1
        }
        
        return self.transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return 60
        } else if (indexPath.section == 1 && transactions.count == 0){
            return 250
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            let cell:ReferralStatsCell = tableView.dequeueReusableCell(withIdentifier: "referralStatsCell") as! ReferralStatsCell
            if (indexPath.row == 0){
                cell.titleLabel.text = NSLocalizedString("amount_invited", comment: "")
                cell.amountLabel.text = String(User.currentUser.totalReferred)
                cell.iconImageView.image = #imageLiteral(resourceName: "ic_team_users")
            } else if (indexPath.row == 1){
                cell.titleLabel.text = NSLocalizedString("amount_transaction", comment: "")
                cell.amountLabel.text = String(User.currentUser.totalTransaction)
                cell.iconImageView.image = #imageLiteral(resourceName: "ic_mobile_stats")
            } else if (indexPath.row == 2){
                cell.titleLabel.text = NSLocalizedString("amount_earning_referral", comment: "")
                cell.amountLabel.text = String(User.currentUser.totalCoin)
                cell.iconImageView.image = #imageLiteral(resourceName: "ic_coin_pill")
            }
            
            return cell
        } else if (indexPath.section == 1 && self.transactions.count == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell") as! EmptyCell
            cell.iconImageView.image = #imageLiteral(resourceName: "ic_pill_zanicoins")
            cell.detailsLabel.text = NSLocalizedString("empty_referral_transaction", comment: "")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "referralTransactionCell") as! ReferralTransactionCell
        let transaction = self.transactions[indexPath.row]
        
        if let createdAt = Date(fromString: transaction.createdAt, format: .custom("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"), timeZone: .utc) {
            cell.dateLabel.text = String.localizedStringWithFormat(NSLocalizedString("created_at", comment: ""), createdAt.toString(format: .custom("EEEE dd MMM HH:mm"), timeZone: .local))
        } else {
            cell.dateLabel.text = ""
        }
        
        cell.descriptionLabel.text = transaction.description
        cell.usernameLabel.text = transaction.sourceRef
        
        if (transaction.type == "Referral-Coin"){
            cell.amountLabel.text = String(transaction.amount) + " ZC"
        } else if (transaction.type == "Referral-Jeton"){
            cell.amountLabel.text = String.localizedStringWithFormat(NSLocalizedString("", comment: ""), transaction.amount)
        } else {
            cell.amountLabel.text = String(transaction.amount) + " ZC"
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func fetchTransactions(completition: (()-> Void)?){
        KRProgressHUD.show()
        Alamofire.request(TransactionRouter.getReferralTransactions())
            .validate()
            .responseArray { (response: DataResponse<[Transaction]>) in
                KRProgressHUD.dismiss()
                switch(response.result){
                case .success(let value):
                    self.transactions.append(contentsOf: value)
                    self.invitedTableView.reloadData()
                    break
                case .failure(let error):
                    break
                }
            }
    }

}
