//
//  ShopController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SCLAlertView
import UIEmptyState
import NVActivityIndicatorView
import ChameleonFramework

class ShopController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsValueLabel: UILabel!
    @IBOutlet weak var shopTableView: UITableView!
    
    
    var rewards:[Reward] = []
    var indicatorView:NVActivityIndicatorView!
    var baseInset:CGFloat = -20
    var networkError:Bool = false
    var internetError:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("title_shop", comment: "")
        self.shopTableView.delegate = self
        self.shopTableView.dataSource = self
        
        self.pointsLabel.text = "\(User.currentUser.point!) ZANICOINS"
        //self.pointsValueLabel.text = "\(Double(User.currentUser.point) * 0.000016)€"
        self.pointsValueLabel.text = NSLocalizedString("shop_description", comment: "")
        self.pointsValueLabel.numberOfLines = 0

        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        // Optionally remove seperator lines from empty cells
        self.shopTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: (self.view.bounds.width/2)-25, y: (self.view.bounds.height/2)-29, width: 50, height: 50) )
        self.indicatorView!.type = .ballClipRotateMultiple
        self.indicatorView!.color = .flatGreen
        self.view.addSubview(self.indicatorView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseInset = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emptyStateView.isHidden = true
        if (rewards.count == 0){
            self.indicatorView!.startAnimating()
        }
        
        fetchRewards()
        UserService.refreshData {
            self.pointsLabel.text = "\(User.currentUser.point!) ZANICOINS"
        }
        
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
    
    var emptyStateImage: UIImage? {
        if (networkError || internetError){
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
        
        return NSAttributedString(string: NSLocalizedString("empty_reward", comment: ""), attributes: attrs)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rewards.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rewardCell", for: indexPath) as! RewardCell
        let reward = self.rewards[indexPath.row]
        cell.rewardNameLabel.text = String.localizedStringWithFormat(NSLocalizedString("reward_title", comment: ""), reward.name,reward.amount!)
        cell.pointsPriceLabel.text = "\(reward.price!) ZANICOINS"
        if (reward.brand == "PayPal"){
            let gradient:UIColor = GradientColor(UIGradientStyle.topToBottom, frame: cell.contentView.frame, colors: [UIColor.flatSkyBlue, UIColor.flatSkyBlueDark])
            let subView = UIView(frame: cell.stackView.bounds)
            subView.backgroundColor = gradient
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cell.stackView.insertSubview(subView, at: 0)
            
            cell.rewardImageView.image = #imageLiteral(resourceName: "ic_paypal_reward")
            cell.pointsPriceLabel.textColor = gradient
        } else if (reward.brand == "Amazon"){
            let gradient:UIColor = GradientColor(UIGradientStyle.topToBottom, frame: cell.contentView.frame, colors: [UIColor.flatOrange, UIColor.flatOrangeDark])
            cell.contentView.backgroundColor = gradient
            cell.rewardImageView.image = #imageLiteral(resourceName: "ic_amazon_reward")
            cell.pointsPriceLabel.textColor = gradient
        } else {
            let gradient:UIColor = GradientColor(UIGradientStyle.topToBottom, frame: cell.contentView.frame, colors: [UIColor.flatGreen, UIColor.flatGreenDark])
            cell.contentView.backgroundColor = gradient
            cell.rewardImageView.image = #imageLiteral(resourceName: "zanibet_logo")
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let reward = self.rewards[indexPath.row]
        let alertView = SCLAlertView(appearance:  SCLAlertView.SCLAppearance(
            showCloseButton: false
        ))
        
        if (User.currentUser.point < reward.price){
            alertView.addButton(NSLocalizedString("ok_exclamation", comment: "")) {
            }
            alertView.showError("Oups", subTitle: NSLocalizedString("err_not_enough_fund", comment: ""))
        } else {
            alertView.addButton(NSLocalizedString("confirm_buy", comment: "")) {
                self.buyReward(reward: reward)
            }
            alertView.addButton(NSLocalizedString("cancel", comment: "")) {
            }
            
            alertView.showNotice(NSLocalizedString("dlg_title_confirm_reward", comment: ""), subTitle: String.localizedStringWithFormat(NSLocalizedString("reward_confirm", comment: ""), reward.price!, reward.name!, reward.amount!))
        }
    }

    func buyReward(reward:Reward){
        let params:[String:Any] = ["_id": reward.id]
        self.indicatorView.startAnimating()
        Alamofire.request(PayoutRouter.postPayoutReward(params)).validate().responseJSON {
            response in
            
            let alertView = SCLAlertView(appearance:  SCLAlertView.SCLAppearance(
                showCloseButton: false
            ))
            alertView.addButton(NSLocalizedString("ok_exclamation", comment: "")) {
            }
            
            switch(response.result){
            case .success:
                UserService.refreshData {
                    self.indicatorView.stopAnimating()
                    self.pointsLabel.text = "\(User.currentUser.point!) ZANICOINS"
                    alertView.showSuccess("Youha !", subTitle: NSLocalizedString("dlg_content_payout_reward", comment: ""))
                }
                break
            case .failure(let error):
                self.indicatorView.stopAnimating()
                if let err = error as? URLError
                {
                    if (err.code == URLError.Code.notConnectedToInternet){
                        // No internet
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                           alertView.showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("err_network", comment: ""))
                        }
                    } else if (err.code.rawValue == -1004){
                        // Serveur indisponible
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            alertView.showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("maintenance_mode", comment: ""))
                        }
                    }
                } else {
                    // Other errors
                    if let data = response.data {
                        let json = JSON(data)
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            alertView.showError("Oups", subTitle: json["detail"].stringValue)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            alertView.showError("Oups", subTitle: NSLocalizedString("err_internal", comment: ""))
                        }
                    }
                }
                break
            }
        }
    }
    
    func fetchRewards(){
        self.internetError = false
        self.networkError = false
        Alamofire.request(ShopRouter.getRewards()).validate().responseArray { (response: DataResponse<[Reward]>) in
            self.indicatorView.stopAnimating()
            switch (response.result){
            case .success:
                self.rewards = response.result.value!
                self.shopTableView.reloadData()
                self.reloadEmptyStateForTableView(self.shopTableView)
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
                self.rewards.removeAll()
                self.shopTableView.reloadData()
                self.reloadEmptyStateForTableView(self.shopTableView)
            }
        }
    }
}
