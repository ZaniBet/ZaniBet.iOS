//
//  Odds.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 01/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Odds: Mappable {
    
    var type: String!
    var bookmaker: String!
    var value: OddsValue?
    
    struct OddsValue: Mappable {
        var homeTeam: Float?
        var draw: Float?
        var awayTeam: Float?
        var positive: Float?
        var negative: Float?
        
        init?(map:Map){
            
        }
        
        mutating func mapping(map: Map) {
            homeTeam <- map["homeTeam"]
            draw <- map["draw"]
            awayTeam <- map["awayTeam"]
            positive <- map["positive"]
            negative <- map["negative"]
        }
    }
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        type <- map["type"]
        bookmaker <- map["bookmaker"]
        value <- map["odds"]
    }
    
}
