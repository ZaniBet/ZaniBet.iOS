//
//  Fixture.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 26/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Fixture: Mappable {
    
    var id:String!
    var competition:Competition?
    var date:String!
    var matchDay:Int?
    var homeTeam:Team!
    var awayTeam:Team!
    var winner:Int?
    var homeScore:Int?
    var awayScore:Int?
    var status:String?
    var odds: [Odds]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        date <- map["date"]
        competition <- map["competition"]
        homeTeam <- map["homeTeam"]
        awayTeam <- map["awayTeam"]
        status <- map["status"]
        winner <- map["result.winner"]
        homeScore <- map["result.homeScore"]
        awayScore <- map["result.awayScore"]
        odds <- map["odds"]

    }
    
}
