//
//  LoadingController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 24/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit
import KeychainSwift
import NVActivityIndicatorView
import SCLAlertView
import FirebaseMessaging
import SwiftyJSON
import DefaultsKit

class LoadingController: UIViewController {
    
    @IBOutlet weak var indicatorView: NVActivityIndicatorView!
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicatorView!.type = .ballClipRotateMultiple
        self.indicatorView!.color = .white
        self.indicatorView.startAnimating()
        self.updateExtra()
        self.getSettings()
        if (FBSDKAccessToken.current() != nil && keychain.get("access_token") == nil){
            self.loginWithFacebook()
        } else {
            self.checkAccessToken()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateExtra(){
        let params:[String:Any] = ["locale": Locale.current.languageCode ?? "null"]
        Alamofire.request(UserRouter.putExtra(params)).validate();
    }
    
    func getSettings(){
        Alamofire.request(DataRouter.getSettings())
            .validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("JSON: \(json)")
                    let defaults = Defaults()
                    for (_,setting):(String, JSON) in json{
                        defaults.set(setting["value"].intValue, for: Key<Int>(setting["setting"].stringValue) )
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func checkAccessToken(){
        Alamofire.request(UserRouter.getUser())
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("Validation Successful")
                    let json = JSON(value)
                    User.currentUser.id = json["_id"].stringValue
                    User.currentUser.email = json["email"].stringValue
                    User.currentUser.username = json["username"].stringValue
                    User.currentUser.lastName = json["lastname"].stringValue
                    User.currentUser.firstName = json["firstname"].stringValue
                    User.currentUser.point = json["point"].intValue
                    User.currentUser.paypal = json["paypal"].stringValue
                    User.currentUser.street = json["address"]["street"].stringValue
                    User.currentUser.city = json["address"]["city"].stringValue
                    User.currentUser.zipcode = json["address"]["zipcode"].stringValue
                    User.currentUser.country = json["address"]["country"].stringValue
                    User.currentUser.fcmToken = json["fcmToken"].stringValue
                    User.currentUser.jeton = json["jeton"].intValue
                    User.currentUser.invitationCode = json["referral"]["invitationCode"].stringValue
                    User.currentUser.invitationBonus = json["referral"]["invitationBonus"].intValue
                    User.currentUser.coinRewardPercent = json["referral"]["coinRewardPercent"].intValue
                    User.currentUser.jetonReward = json["referral"]["jetonReward"].intValue
                    User.currentUser.totalReferred = json["referral"]["totalReferred"].intValue
                    User.currentUser.totalTransaction = json["referral"]["totalTransaction"].intValue
                    User.currentUser.totalCoin = json["referral"]["totalCoin"].intValue
                    User.currentUser.totalJeton = json["referral"]["totalJeton"].intValue
                    User.currentUser.saveUser()
                    let mainController = self.storyboard!.instantiateViewController(withIdentifier: "MainController")
                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                        self.show(mainController, sender: nil)
                    }
                    
                    
                    break
                case .failure(let error):
                    // Login error
                    print(error)
                    if (response.response?.statusCode == 401){
                        User.currentUser.clearUser()
                    }
                    let loginController = self.storyboard!.instantiateViewController(withIdentifier: "LoginController")
                    self.show(loginController, sender: nil)
                    
                    break
                }
        }
    }
    
    func loginWithFacebook(){
        let params:[String:Any] = ["accessToken": FBSDKAccessToken.current().tokenString]
        Alamofire.request(AuthRouter.postSigninWithFacebook(params)).validate().responseJSON {
            response in
            switch response.result {
            case .success:
                
                if let json = response.result.value as? [String: Any] {
                    self.keychain.set(json["access_token"] as! String, forKey: "access_token")
                    self.checkAccessToken()
                }
            case .failure(let error):
                // Login error
                if let err = error as? URLError
                {
                    if (err.code == URLError.Code.notConnectedToInternet){
                        // No internet
                        SCLAlertView().showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("err_network", comment: ""))
                    } else if (err.code.rawValue == -1004){
                        // Serveur indisponible
                        SCLAlertView().showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("maintenance_mode", comment: ""))
                    }
                } else {
                    // Other errors
                }
            }
        }
    }
    
}
