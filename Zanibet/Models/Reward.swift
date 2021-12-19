//
//  Reward.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 27/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Reward: Mappable {
    
    var id:String!
    var name:String!
    var brand:String!
    var amount:Double!
    var price:Int!
    
    required init?(map: Map){
        
    }
    

    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        brand <- map["brand"]
        amount <- map["amount.euro"]
        price <- map["price"]
    }
    
}
