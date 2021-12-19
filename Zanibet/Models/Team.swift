//
//  Team.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 26/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Team: Mappable {
    
    var id:String!
    var name:String!
    var shortName:String?
    var logo:String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["_id"]
        name <- map["name"]
        shortName <- map["shortName"]
        logo <- map["logo"]
    }
    
}
