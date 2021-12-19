//
//  User.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 25/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import KeychainSwift
import FBSDKLoginKit

let kUserData = "userData"

let kUserId = "userId"
let kUserFacebookId = "userFacebookId"
let kUserFacebookAccessToken = "userFacebookAccessToken"
let kUserUsername = "userUsername"
let kUserFirstName = "userFirstName"
let kUserLastName = "userLastName"
let kUserEmail = "userEmail"
let kUserPoint = "userPoint"
let kUserPaypal = "userPaypal"
let kUserStreet = "userStreet"
let kUserCity = "userCity"
let kUserZipcode = "userZipcode"
let kUserCountry = "userCountry"
let kUserFcmToken = "userFcmToken"
let kUserJeton = "userJeton"

let kUserInvitationCode = "userInvitationCode"
let kUserInvitationBonus = "userInvitationBonus"
let kUserCoinRewardPercent = "userCoinRewardPercent"
let kUserJetonReward = "userJetonReward"
let kUserTotalReferred = "userTotalReferred"
let kUserTotalCoin = "userTotalCoin"
let kUserTotalJeton = "userTotalJeton"
let kUserTotalTransaction = "userTotalTransaction"

class User:NSObject {
    
    var id:String!
    var facebookId:String?
    var facebookAccessToken:String?
    var username:String!
    var firstName:String?
    var lastName:String?
    var email:String!
    var point:Int!
    var paypal:String?
    
    var street:String?
    var city:String?
    var zipcode:String?
    var country:String?
    
    var fcmToken:String?
    var jeton:Int!
    
    var invitationCode:String!
    var invitationBonus:Int!
    var coinRewardPercent:Int!
    var jetonReward:Int!
    var totalReferred:Int!
    var totalCoin:Int!
    var totalJeton:Int!
    var totalTransaction:Int!
    
    class var currentUser: User
    {
        struct Static
        {
            static var instance: User?
        }
        
        if Static.instance == nil
        {
            if let load: AnyObject = UserDefaults.standard.object(forKey: kUserData) as AnyObject?
            {
                Static.instance = User(data: load as! [String: Any])
            }
            else
            {
                Static.instance = User()
            }
        }
        return Static.instance!
    }

    init(data: [String: Any])
    {
        super.init()
        id = data[kUserId] as? String
        facebookId = data[kUserFacebookId] as? String
        facebookAccessToken = data[kUserFacebookAccessToken] as? String
        username = data[kUserUsername] as? String
        firstName = data[kUserFirstName] as? String
        lastName = data[kUserLastName] as? String
        email = data[kUserEmail] as? String
        point = data[kUserPoint] as? Int
        paypal = data[kUserPaypal] as? String
        street = data[kUserStreet] as? String
        city = data[kUserCity] as? String
        zipcode = data[kUserZipcode] as? String
        country = data[kUserCountry] as? String
        fcmToken = data[kUserFcmToken] as? String
        jeton = data[kUserJeton] as? Int
        invitationCode = data[kUserInvitationCode] as? String
        invitationBonus = data[kUserInvitationBonus] as? Int
        coinRewardPercent = data[kUserCoinRewardPercent] as? Int
        jetonReward = data[kUserJetonReward] as? Int
        totalCoin = data[kUserTotalCoin] as? Int
        totalJeton = data[kUserTotalJeton] as? Int
        totalReferred = data[kUserTotalReferred] as? Int
        totalTransaction = data[kUserTotalTransaction] as? Int
    }
    
    override init()
    {
        super.init()
        id = ""
        facebookId = ""
        facebookAccessToken = ""
        username = ""
        firstName = ""
        lastName = ""
        email = ""
        point = 0
        paypal = ""
        street = ""
        city = ""
        zipcode = ""
        country = ""
        fcmToken = ""
        jeton = 0
        invitationCode = ""
        invitationBonus = 0
        coinRewardPercent = 0
        jetonReward = 0
        totalCoin = 0
        totalJeton = 0
        totalReferred = 0
        totalTransaction = 0
    }

    func saveUser(){
        var data: [String: Any] = [:]
        data[kUserId] = id as Any?
        data[kUserFirstName] = firstName as Any?
        data[kUserLastName] = lastName as Any?
        data[kUserEmail] = email as Any?
        data[kUserPoint] = point as Any?
        data[kUserStreet] = street as Any?
        data[kUserZipcode] = zipcode as Any?
        data[kUserCity] = city as Any?
        data[kUserCountry] = country as Any?
        data[kUserFcmToken] = fcmToken as Any?
        data[kUserJeton] = jeton as Any?
        data[kUserInvitationCode] = invitationCode as Any?
        data[kUserInvitationBonus] = invitationBonus as Any?
        data[kUserCoinRewardPercent] = coinRewardPercent as Any?
        data[kUserJetonReward] = jetonReward as Any?
        data[kUserTotalCoin] = totalCoin as Any?
        data[kUserTotalJeton] = totalJeton as Any?
        data[kUserTotalReferred] = totalReferred as Any?
        data[kUserTotalTransaction] = totalTransaction as Any?
        UserDefaults.standard.set(data, forKey: kUserData)
    }
    
    func clearUser(){
        FBSDKLoginManager.init().logOut()
        let keychain = KeychainSwift()
        keychain.delete("access_token")
        UserDefaults.standard.removeObject(forKey: kUserData)
    }
    
    
}
