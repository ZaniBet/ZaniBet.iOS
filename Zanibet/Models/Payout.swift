//
//  Profile.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 01/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Payout: Mappable {
    
    var createdAt:String!
    var id:String!
    var kind:String!
    var target:[String:Any]?
    var amount:Double!
    var status:String!
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        createdAt <- map["createdAt"]
        id <- map["_id"]
        kind <- map["kind"]
        target <- map["target"]
        amount <- map["amount"]
        status <- map["status"]
    }
    
}
