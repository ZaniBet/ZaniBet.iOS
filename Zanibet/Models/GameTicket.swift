//
//  GameTicket.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 26/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class GameTicket: Mappable {
    
    var id:String!
    var name:String!
    var cover:String!
    var picture:String!
    var thumbnail:String?
    var jackpot:Int!
    var openDate:String!
    var limitDate:String!
    var resultDate:String!
    var maxNumberOfPlay:Int!
    var numberOfGrillePlay:Int!
    var status:String!
    var type:String!
    var matchday:Int?
    var fixtures:[Fixture]!
    var competition:Competition?
    var pointsPerBet:Int!
    var bonus:Int!
    var bonusActivation:Int!
    var jeton:Int!
    var betsType:[BetType]?
    
    required init!(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        cover <- map["cover"]
        picture <- map["picture"]
        thumbnail <- map["thumbnail"]
        jackpot <- map["jackpot"]
        openDate <- map["openDate"]
        limitDate <- map["limitDate"]
        resultDate <- map["resultDate"]
        maxNumberOfPlay <- map["maxNumberOfPlay"]
        numberOfGrillePlay <- map["numberOfGrillePlay"]
        status <- map["status"]
        type <- map["type"]
        matchday <- map["matchDay"]
        fixtures <- map["fixtures"]
        competition <- map["competition"]
        pointsPerBet <- map["pointsPerBet"]
        bonus <- map["bonus"]
        bonusActivation <- map["bonusActivation"]
        jeton <- map["jeton"]
        betsType <- map["betsType"]
    }
}
