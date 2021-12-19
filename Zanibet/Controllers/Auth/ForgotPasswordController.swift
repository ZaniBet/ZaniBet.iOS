//
//  ForgotPasswordController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import KRProgressHUD
import Alamofire
import SwiftyJSON
import KeychainSwift
import Validator
import SCLAlertView

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    enum ValidationErrors: String, Error {
        case emailInvalid = "Adresse email incorrecte"
        var message:String { return self.rawValue }
    }
    
    let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error:ValidationErrors.emailInvalid)
    
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
    
    @IBAction func resetPasswordTouched(_ sender: Any) {
        let emailResult = self.emailTextField.text!.validate(rule: self.emailRule)
        if (emailResult.isValid){
            self.resetPassword()
        } else {
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("edit_err_email", comment: ""))
        }
     }
    
    func resetPassword(){
        KRProgressHUD.show(withMessage: NSLocalizedString("ldg_content_restore_password", comment: ""))

        let params:[String:Any] = ["email": emailTextField.text!.lowercased()]
        Alamofire.request(AuthRouter.putResetPassword(params)).validate().responseJSON {
            response in
            switch response.result {
            case .success:
                KRProgressHUD.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                SCLAlertView().showSuccess("Youha", subTitle: NSLocalizedString("dlg_content_restore_password", comment: ""))
                }

                break
            case .failure(let error):
                // Reset password fail
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
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            SCLAlertView().showError("Oups", subTitle: json["detail"].stringValue)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_internal", comment: ""))
                        }
                    }
                }
                break
            }
        }
    }
}
