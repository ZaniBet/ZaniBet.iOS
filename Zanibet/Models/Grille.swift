//
//  Grille.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 27/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Grille: Mappable {
    
    var id:String!
    var createdAt:String!
    var updatedAt:String!
    var bets:[Bet]!
    var gameTicket:GameTicket!
    var status:String!
    var payoutAmount:Double?
    var payoutPoint:Int?
    var numberOfBetsWin:Int?
    var type:String!
    var reference:String!
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        createdAt <- map["createdAt"]
        updatedAt <- map["updatedAt"]
        bets <- map["bets"]
        gameTicket <- map["gameTicket"]
        status <- map["status"]
        payoutAmount <- map["payout.amount"]
        payoutPoint <- map["payout.point"]
        numberOfBetsWin <- map["numberOfBetsWin"]
        type <- map["type"]
        reference <- map["reference"]
    }
    
}
