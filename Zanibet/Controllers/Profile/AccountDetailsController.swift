//
//  AccountDetailsController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 29/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Validator
import SCLAlertView
import Alamofire
import SwiftyJSON
import ChameleonFramework
import KRProgressHUD

class AccountDetailsController: UIViewController {
    @IBOutlet weak var usernameTextField: HoshiTextField!
    @IBOutlet weak var emailTextField: HoshiTextField!
    
    @IBOutlet weak var saveButton: RoundedButton!
    
    enum ValidationErrors: String, Error {
        case emailInvalid = "Adresse email incorrecte"
        var message:String { return self.rawValue }
    }
    
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error:ValidationErrors.emailInvalid)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.isEnabled = false
        self.usernameTextField.text = User.currentUser.username!
        self.emailTextField.text = User.currentUser.email
        self.saveButton.backgroundColor = HexColor("#4CAF50")

        var emailRules = ValidationRuleSet<String>()
        emailRules.add(rule: self.emailRule)
        self.emailTextField.validationRules = emailRules
        self.emailTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.emailTextField.rightViewMode = .never
            case .invalid( _):
               //print(failureErrors)
               self.emailTextField.rightViewMode = .always
               self.emailTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.emailTextField.validateOnInputChange(enabled: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.saveButton.layer.cornerRadius = 22.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveTouched(_ sender: Any) {
        let emailResult = self.emailTextField.validate(rule: emailRule)
        if (emailResult.isValid){
            KRProgressHUD.show(withMessage: NSLocalizedString("ldg_content_update_email", comment: ""))
            self.updateEmail()
        } else {
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("edit_err_email", comment: ""))
        }
    }
    
    func updateEmail(){
        let params:[String:Any] = ["email": self.emailTextField.text!]
        Alamofire.request(UserRouter.putUserEmail(params)).validate().responseJSON {
            response in
            KRProgressHUD.dismiss()
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                User.currentUser.lastName = json["lastname"].stringValue
                User.currentUser.firstName = json["firstname"].stringValue
                User.currentUser.paypal = json["paypal"].stringValue
                User.currentUser.street = json["address"]["street"].stringValue
                User.currentUser.city = json["address"]["city"].stringValue
                User.currentUser.zipcode = json["address"]["zipcode"].stringValue
                User.currentUser.country = json["address"]["country"].stringValue
                User.currentUser.saveUser()
                
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("OK") {
                    self.dismiss(animated: true, completion: nil)
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    alertView.showSuccess("Youhah !", subTitle: NSLocalizedString("dlg_content_update_email", comment: ""))
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
                            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_internal", comment: ""))
                        }
                    }
                }
            }
        }
    }
    
}
