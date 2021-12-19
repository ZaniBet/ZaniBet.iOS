//
//  PaiementDetailsController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 29/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import ChameleonFramework
import Validator
import Alamofire
import SCLAlertView
import SwiftyJSON
import KRProgressHUD

class PaiementDetailsController: UIViewController {
    
    @IBOutlet weak var lastNameTextField: HoshiTextField!
    @IBOutlet weak var firstNameTextField: HoshiTextField!
    @IBOutlet weak var addressTextField: HoshiTextField!
    @IBOutlet weak var zipcodeTextField: HoshiTextField!
    @IBOutlet weak var cityTextField: HoshiTextField!
    @IBOutlet weak var countryTextField: HoshiTextField!
    @IBOutlet weak var paypalTextField: HoshiTextField!
    @IBOutlet weak var saveButton: UIButton!
    
    enum ValidationErrors: String, Error {
        case lastNameInvalid = "Merci d'indiquer votre nom"
        case firstNameInvalid = "Merci d'indiquer votre prénom"
        case addressInvalid = ""
        case zipInvalid = "Code postal incorrect"
        case cityInvalid = "Ville incorrecte"
        case countryInvalid = "Pays incorrecte"
        case paypalInvalid = "Adresse PayPal incorrecte"
        var message:String { return self.rawValue }
    }
    
    let paypalRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationErrors.paypalInvalid)
    let firstNameRule = ValidationRuleLength(min:2, max: 54, error: ValidationErrors.firstNameInvalid)
    let lastNameRule = ValidationRuleLength(min:2, max: 54, error: ValidationErrors.lastNameInvalid)
    let addressRule = ValidationRuleLength(min:2, max: 54, error: ValidationErrors.addressInvalid)
    let zipRule = ValidationRuleLength(min:2, max: 6, error: ValidationErrors.zipInvalid)
    let cityRule = ValidationRuleLength(min:2, max: 54, error: ValidationErrors.cityInvalid)
    let countryRule = ValidationRuleLength(min:2, max: 54, error: ValidationErrors.countryInvalid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.saveButton.backgroundColor = HexColor("#4CAF50")
        self.initValidationRules()
    }
    
    
    
    func initValidationRules(){
        // lastname
        var lastNameRules = ValidationRuleSet<String>()
        lastNameRules.add(rule: self.lastNameRule)
        self.lastNameTextField.validationRules = lastNameRules
        self.lastNameTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.lastNameTextField.rightViewMode = .never
            case .invalid( _):
                //print(failureErrors)
                self.lastNameTextField.rightViewMode = .always
                self.lastNameTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.lastNameTextField.validateOnInputChange(enabled: true)
        
        // firstname
        var firstNameRules = ValidationRuleSet<String>()
        firstNameRules.add(rule: self.firstNameRule)
        self.firstNameTextField.validationRules = firstNameRules
        self.firstNameTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.firstNameTextField.rightViewMode = .never
            case .invalid( _):
                //print(failureErrors)
                self.firstNameTextField.rightViewMode = .always
                self.firstNameTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.firstNameTextField.validateOnInputChange(enabled: true)
        
        // address
        var addressRules = ValidationRuleSet<String>()
        addressRules.add(rule: self.addressRule)
        self.addressTextField.validationRules = addressRules
        self.addressTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.addressTextField.rightViewMode = .never
            case .invalid( _):
                //print(failureErrors)
                self.addressTextField.rightViewMode = .always
                self.addressTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.addressTextField.validateOnInputChange(enabled: true)
        
        //zip
        var zipRules = ValidationRuleSet<String>()
        zipRules.add(rule: self.zipRule)
        self.zipcodeTextField.validationRules = zipRules
        self.zipcodeTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.zipcodeTextField.rightViewMode = .never
            case .invalid( _):
                //print(failureErrors)
                self.zipcodeTextField.rightViewMode = .always
                self.zipcodeTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.zipcodeTextField.validateOnInputChange(enabled: true)
        
        // city
        var cityRules = ValidationRuleSet<String>()
        cityRules.add(rule: self.cityRule)
        self.cityTextField.validationRules = cityRules
        self.cityTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.cityTextField.rightViewMode = .never
            case .invalid( _):
                ///print(failureErrors)
                self.cityTextField.rightViewMode = .always
                self.cityTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.cityTextField.validateOnInputChange(enabled: true)
        
        // country
        var countryRules = ValidationRuleSet<String>()
        countryRules.add(rule: self.countryRule)
        self.countryTextField.validationRules = countryRules
        self.countryTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.countryTextField.rightViewMode = .never
            case .invalid( _):
                //print(failureErrors)
                self.countryTextField.rightViewMode = .always
                self.countryTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.addressTextField.validateOnInputChange(enabled: true)
        
        //paypal
        var paypalRules = ValidationRuleSet<String>()
        paypalRules.add(rule: self.paypalRule)
        self.paypalTextField.validationRules = paypalRules
        self.paypalTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.paypalTextField.rightViewMode = .never
            case .invalid( _):
                //print(failureErrors)
                self.paypalTextField.rightViewMode = .always
                self.paypalTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.paypalTextField.validateOnInputChange(enabled: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.paypalTextField.text = User.currentUser.paypal
        self.firstNameTextField.text = User.currentUser.firstName
        self.lastNameTextField.text = User.currentUser.lastName
        self.addressTextField.text = User.currentUser.street
        self.zipcodeTextField.text = User.currentUser.zipcode
        self.cityTextField.text = User.currentUser.city
        self.countryTextField.text = User.currentUser.country
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTouched(_ sender: Any) {
        let lastNameResult = self.lastNameTextField.text!.validate(rule: self.lastNameRule)
        let firstNameResult = self.firstNameTextField.text!.validate(rule: self.firstNameRule)
        let addressResult = self.addressTextField.text!.validate(rule: self.addressRule)
        let cityResult = self.cityTextField.text!.validate(rule: self.cityRule)
        let zipResult = self.zipcodeTextField.text!.validate(rule: self.zipRule)
        let countryResult = self.countryTextField.text!.validate(rule: self.countryRule)
        let paypalResult = self.paypalTextField.text!.validate(rule: self.paypalRule)
        
        if (lastNameResult.isValid && firstNameResult.isValid && addressResult.isValid
            && cityResult.isValid && zipResult.isValid && countryResult.isValid && paypalResult.isValid){
            KRProgressHUD.show(withMessage: NSLocalizedString("ldg_content_update_paiement", comment: ""))

            self.changePaiementData()
        } else {
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_fill_field", comment: ""))
        }
    }
    
    func changePaiementData(){
        let address = ["street" : self.addressTextField.text!,
                       "city": self.cityTextField.text!,
                       "zipcode": self.zipcodeTextField.text!,
                       "country": self.countryTextField.text!]
        let params:[String:Any] = ["lastname":self.lastNameTextField.text!,
                                   "firstname":self.firstNameTextField.text!,
                                   "paypal": self.paypalTextField.text!,
                                   "address": address]
        Alamofire.request(UserRouter.putUser(params)).validate().responseJSON {
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
                    alertView.showSuccess("Youhah !", subTitle: NSLocalizedString("dlg_content_update_paiement", comment: ""))
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
