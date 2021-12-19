//
//  Competition.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 29/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Competition: Mappable {
    
    var id:String!
    var logo:String?
    var name:String!
    var country:String!
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        country <- map["country"]
        logo <- map["logo"]
        
    }
    
}

