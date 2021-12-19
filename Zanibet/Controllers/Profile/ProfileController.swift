//
//  ProfileController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftIcons
import SwiftyJSON
import KRProgressHUD

class ProfileController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    
    let menuArray:[String] = [NSLocalizedString("menu_my_account", comment: ""),NSLocalizedString("menu_paiement_info", comment: ""), NSLocalizedString("menu_paiement_history", comment: ""),NSLocalizedString("invitation_code", comment: ""), NSLocalizedString("share_with_friends", comment: ""), NSLocalizedString("menu_rules", comment: ""), NSLocalizedString("menu_about", comment: ""), NSLocalizedString("menu_disconnect", comment: "")]
    let iconArray:[UIImage] = [
        UIImage.init(icon: .emoji(.user), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray),
        UIImage.init(icon: .fontAwesomeSolid(.idCard), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray),
        UIImage.init(icon: .fontAwesomeSolid(.gift), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray),
        UIImage.init(icon: .fontAwesomeSolid(.gift), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray),
        UIImage.init(icon: .fontAwesomeSolid(.shareSquare), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray),
        UIImage.init(icon: .fontAwesomeSolid(.gavel), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray),
        UIImage.init(icon: .fontAwesomeSolid(.questionCircle), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray),
        UIImage.init(icon: .fontAwesomeSolid(.gavel), size: CGSize(width: 24, height: 24), textColor: UIColor.flatGray)]
    var baseInset:CGFloat = -20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("title_profile", comment: "")
        self.profileTableView.dataSource = self
        self.profileTableView.delegate = self
        
        self.usernameLabel.text = "\(User.currentUser.username!)"
        self.pointsLabel.text = "\(User.currentUser.point!) ZANICOINS"
        self.profileImageView.layer.cornerRadius = 40
        
        // Optionally remove seperator lines from empty cells
        self.profileTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baseInset = 0
        fetchUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileTwoLineCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("menu_paiement_info", comment: "")
            cell.detailTextLabel?.text = NSLocalizedString("menu_paiement_detail", comment: "")
            cell.imageView?.image = self.iconArray[indexPath.row]
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileSingleLineCell", for: indexPath)
            cell.textLabel?.text = menuArray[indexPath.row]
            cell.imageView?.image = self.iconArray[indexPath.row]
            return cell;
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.row){
        case 0:
            let accountDetailsController = self.storyboard?.instantiateViewController(withIdentifier: "AccountDetailsController") as! AccountDetailsController
            self.present(accountDetailsController, animated: true, completion: nil)
            break
        case 1:
            let paiementDetailsController = self.storyboard?.instantiateViewController(withIdentifier: "PaiementDetailsController") as! PaiementDetailsController
            self.present(paiementDetailsController, animated: true, completion: nil)
            break
        case 2:
            let payoutController = self.storyboard?.instantiateViewController(withIdentifier: "PayoutController") as! PayoutController
            self.show(payoutController, sender: nil)
            break
        case 3:
            let referralStoryboard = UIStoryboard(name: "Referral", bundle: nil)
            let invitationCodeController = referralStoryboard.instantiateViewController(withIdentifier: "InvitationCodeController") as! InvitationCodeController
            self.show(invitationCodeController, sender: nil)
            //self.present(invitationCodeController, animated: true, completion: nil)
            break
        case 4:
            let referralStoryboard = UIStoryboard(name: "Referral", bundle: nil)
            let referralController = referralStoryboard.instantiateViewController(withIdentifier: "ReferralController") as! ReferralController
            self.show(referralController, sender: nil)
            //self.present(referralController, animated: true, completion: nil)
            break
        case 5:
            //let gameRulesController = self.storyboard?.instantiateViewController(withIdentifier: "GameRulesController") as! GameRulesController
                    let helpWebController = self.storyboard?.instantiateViewController(withIdentifier: "HelpWebController") as! HelpWebController
            self.present(helpWebController, animated: true, completion: nil)
            break
        case 6:
            let aboutController = self.storyboard?.instantiateViewController(withIdentifier: "AboutController") as! AboutController
            self.present(aboutController, animated: true, completion: nil)
            break
        case 7:
            User.currentUser.clearUser()
            let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as! LoginController
            self.present(loginController, animated: true, completion: { 
                
            })
            break
        default:
            break
        }
    }
    
    
    func fetchUser(){
        Alamofire.request(UserRouter.getUser()).validate().responseJSON {
            response in
            switch(response.result){
            case .success(let value):
                let json = JSON(value)
                //print(json)
                User.currentUser.email = json["email"].stringValue
                User.currentUser.point = json["point"].intValue
                User.currentUser.lastName = json["lastname"].stringValue
                User.currentUser.firstName = json["firstname"].stringValue
                User.currentUser.paypal = json["paypal"].stringValue
                User.currentUser.street = json["address"]["street"].stringValue
                User.currentUser.city = json["address"]["city"].stringValue
                User.currentUser.zipcode = json["address"]["zipcode"].stringValue
                User.currentUser.country = json["address"]["country"].stringValue
                User.currentUser.saveUser()
                self.usernameLabel.text = "\(User.currentUser.username!)"
                self.pointsLabel.text = "\(User.currentUser.point!) ZANICOINS"
                
                break
            case .failure( _):
                //print(error)
                break
            }
        }
    }
}
