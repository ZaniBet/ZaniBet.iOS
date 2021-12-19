//
//  InvitationCodeController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 20/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SCLAlertView
import KRProgressHUD
import Validator

class InvitationCodeController: UIViewController {
    
    @IBOutlet weak var invitationCodeDescLabel: UILabel!
    @IBOutlet weak var invitationCodeTextField: HoshiTextField!
    @IBOutlet weak var validationButton: RoundedButton!
    
    enum ValidationErrors: String, Error {
        case emailInvalid = "Code d'invitation incorrecte"
        var message:String { return self.rawValue }
    }
    
    let invitationCodeRule = ValidationRuleLength(min:4, max: 24, error: ValidationErrors.emailInvalid)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("invitation_code", comment: "")
        
        self.invitationCodeDescLabel.text = NSLocalizedString("invitation_code_desc", comment: "")
        self.invitationCodeTextField.placeholder = NSLocalizedString("your_invitation_code", comment: "")
        self.validationButton.setTitle(NSLocalizedString("validate", comment: ""), for: UIControlState.normal)
        
        var invitationCodeRules = ValidationRuleSet<String>()
        invitationCodeRules.add(rule: self.invitationCodeRule)
        self.invitationCodeTextField.validationRules = invitationCodeRules
        self.invitationCodeTextField.validationHandler = {
            result in
            switch result {
            case .valid:
                //print("valid!")
                self.invitationCodeTextField.rightViewMode = .never
            case .invalid( _):
                //print(failureErrors)
                self.invitationCodeTextField.rightViewMode = .always
                self.invitationCodeTextField.rightView = UIImageView(image: UIImage(named: "ic_error_red"))
            }
        }
        self.invitationCodeTextField.validateOnInputChange(enabled: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.validationButton.layer.cornerRadius = 22.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func validateTouched(_ sender: Any) {
        let validationResult = self.invitationCodeTextField.validate(rule: invitationCodeRule)
        if (validationResult.isValid){
            KRProgressHUD.show(withMessage: NSLocalizedString("ldg_content_set_invitation_code", comment: ""))
            self.validateCode(code: self.invitationCodeTextField.text!)
        } else {
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("edit_err_invitation_code", comment: ""))
        }
    }
    
    func validateCode(code:String){
        Alamofire.request(UserRouter.putInvitationCode(code))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    KRProgressHUD.dismiss()
                    let json = JSON(value)
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        SCLAlertView().showSuccess(NSLocalizedString("youha", comment: ""), subTitle: String.localizedStringWithFormat(NSLocalizedString("dlg_content_invitation_success", comment: ""), json.intValue))
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
