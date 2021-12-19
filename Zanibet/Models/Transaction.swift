//
//  Transaction.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 21/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Transaction: Mappable {
    
    var id:String!
    var createdAt:String!
    var type:String!
    var description:String!
    var amount:Int!
    var status:String!
    var sourceRef:String!
    
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        createdAt <- map["createdAt"]
        type <- map["type"]
        description <- map["description"]
        amount <- map["amount"]
        status <- map["status"]
        sourceRef <- map["sourceRef"]
    }
    
}
