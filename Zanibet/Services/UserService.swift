//
//  UserService.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 21/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserService {
    
    static func refreshData(completion: (() -> Void)?){
        Alamofire.request(UserRouter.getUser()).validate().responseJSON {
            response in
            switch(response.result){
            case .success(let value):
                let json = JSON(value)
                //print(json)
                User.currentUser.id = json["_id"].stringValue
                User.currentUser.email = json["email"].stringValue
                User.currentUser.username = json["username"].stringValue
                User.currentUser.point = json["point"].intValue
                User.currentUser.lastName = json["lastname"].stringValue
                User.currentUser.firstName = json["firstname"].stringValue
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
                if (completion != nil){
                    completion!()
                }
                break
            case .failure(let error):
                print(error)
                if (completion != nil){
                    completion!()
                }
                break
            }
        }
    }
}
