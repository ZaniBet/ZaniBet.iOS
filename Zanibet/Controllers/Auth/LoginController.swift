//
//  LoginController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import KeychainSwift
import KRProgressHUD
import Validator
import SCLAlertView
import FBSDKLoginKit
import SwiftyJSON

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    enum ValidationErrors: String, Error {
        case emailInvalid = "Adresse email incorrecte"
        case passwordInvalid = "Mot de passe incorrect"
        var message:String { return self.rawValue }
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var facebookButtonView: UIView!
    
    let keychain = KeychainSwift()
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error:ValidationErrors.emailInvalid)
    let passwordRule = ValidationRuleLength(min: 6, max: 256, error: ValidationErrors.passwordInvalid)

    override func viewDidLoad() {
        super.viewDidLoad()
        if let settings = LoginSettings.read() {
            self.emailTextField.text = settings.lastLogin
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(LoginController.showLoading), name: Notification.Name(rawValue: "showLoading"), object: nil)
    }
    
    @objc func showLoading(){
        let loadingController = self.storyboard?.instantiateViewController(withIdentifier: "LoadingController") as! LoadingController
        self.show(loadingController, sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let facebookButton = FBSDKLoginButton.init()
        facebookButton.readPermissions = ["email", "public_profile"]
        facebookButton.delegate = self
        facebookButton.center = CGPoint(x: self.facebookButtonView.bounds.width/2, y: 30)
        self.facebookButtonView.addSubview(facebookButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginTouched(_ sender: Any) {
        let emailResult = self.emailTextField.text!.validate(rule: self.emailRule)
        let passwordResult = self.passwordTextField.text!.validate(rule: self.passwordRule)
        if (emailResult.isValid && passwordResult.isValid){
            self.login()
        } else {
            SCLAlertView().showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("err_authentification_failled", comment: "")) // Error
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error != nil){
            print(error)
        } else {
            if (result.isCancelled){
                
            } else {
                self.loginWithFacebook(token: result.token.tokenString)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func login(){
        KRProgressHUD.show(withMessage: NSLocalizedString("ldg_content_signin", comment: ""))
        let params:[String:Any] = ["username": emailTextField.text!.lowercased(), "password": passwordTextField.text!]
        Alamofire.request(AuthRouter.postSignin(params))
            .validate()
            .responseJSON { response in
                KRProgressHUD.dismiss()
                switch response.result {
                case .success:
                    let loginSettings = LoginSettings(lastLogin: self.emailTextField.text!)
                    loginSettings.write()
                    if let json = response.result.value as? [String: Any] {
                        self.keychain.set(json["access_token"] as! String, forKey: "access_token")
                        let loadingController = self.storyboard!.instantiateViewController(withIdentifier: "LoadingController") as! LoadingController
                        self.show(loadingController, sender: nil)
                    }
                case .failure(let error):
                    // Login error
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
                                SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_authentification_failled", comment: ""))
                            }
                        }
                    }
                }
        }
    }
    
    func loginWithFacebook(token:String){
        let params:[String:Any] = ["accessToken": token]
        Alamofire.request(AuthRouter.postSigninWithFacebook(params)).validate().responseJSON {
            response in
            switch response.result {
            case .success:
                if let json = response.result.value as? [String: Any] {
                    self.keychain.set(json["access_token"] as! String, forKey: "access_token")
                    let loadingController = self.storyboard!.instantiateViewController(withIdentifier: "LoadingController") as! LoadingController
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        self.show(loadingController, sender: nil)
                    }
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
                    if let data = response.data {
                        let json = JSON(data)
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError("Oups", subTitle: json["detail"].stringValue)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_facebook_auth_failled", comment: ""))
                        }
                    }
                }
            }
        }
    }
}
