//
//  RegisterController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import KRProgressHUD
import SwiftyJSON
import Validator
import KeychainSwift

class RegisterController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    enum ValidationErrors: String, Error {
        case usernameInvalid = "Nom d'utilisateur incorrect"
        case emailInvalid = "Adresse email incorrecte"
        case passwordInvalid = "Mot de passe incorrect"
        var message:String { return self.rawValue }
    }
    
    let usernameRule = ValidationRuleLength(min: 2, max: 30, error: ValidationErrors.usernameInvalid)
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error:ValidationErrors.emailInvalid)
    let passwordRule = ValidationRuleLength(min: 6, max: 256, error: ValidationErrors.passwordInvalid)
    let keychain = KeychainSwift()
    let notificationCenter = NotificationCenter.default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func registerTouched(_ sender: Any) {
        let usernameResult = self.usernameTextField.text!.validate(rule: self.usernameRule)
        let emailResult = self.emailTextField.text!.validate(rule: self.emailRule)
        let passwordResult = self.passwordTextField.text!.validate(rule: self.passwordRule)
        if (usernameResult.isValid && emailResult.isValid && passwordResult.isValid){
            self.register()
        } else {
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_fill_field", comment: ""))
        }
    }
    
    func register(){
        KRProgressHUD.show(withMessage: NSLocalizedString("ldg_content_signup", comment: ""))
        
        let params:[String:Any] = ["username": usernameTextField.text!,
                                   "email": emailTextField.text!.lowercased(),
                                   "password": passwordTextField.text!]
        Alamofire.request(AuthRouter.postSignup(params))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let json = response.result.value as? [String: Any] {
                        print("JSON: \(json)")
                        // Account creation success, now signin user
                        Alamofire.request(AuthRouter.postSignin(["username": self.emailTextField.text!, "password": self.passwordTextField.text!])).validate().responseJSON { response in
                            KRProgressHUD.dismiss()
                            switch response.result {
                            case .success:
                                if let json = response.result.value as? [String: Any] {
                                    self.keychain.set(json["access_token"] as! String, forKey: "access_token")
                                }
                                // Login freshly created account success
                                self.dismiss(animated: true, completion: {
                                    self.notificationCenter.post(name: Notification.Name(rawValue: "showLoading"), object: nil)
                                })
                                break
                            case .failure(let error):
                                // Login fail
                                print(error)
                                break
                            }
                        }
                    }
                    break
                case .failure(let error):
                    // Signup account fail
                    KRProgressHUD.dismiss()
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
                                SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_internal", comment: ""))
                            }
                        }
                    }
                    break
                }
        }
    }
}
