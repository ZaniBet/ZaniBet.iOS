//
//  Bet.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 27/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Bet: Mappable {
    
    var fixture:String!
    var result:Int!
    var status:String?
    var type:String?
    
    required init?(map: Map){
        
    }
    
    init(fixtureId: String, result:Int){
        self.fixture = fixtureId
        self.result = result
    }
    
    init(type: String, result:Int){
        self.type = type
        self.result = result
    }
    
    func mapping(map: Map) {
        //id <- map["_id"]
        fixture <- map["fixture"]
        result <- map["result"]
        status <- map["status"]
        type <- map["type"]
    }
    
}
