//
//  BetType.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 07/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

struct BetType : Mappable {
    
    var type: String!
    var result:Int!
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        type <- map["type"]
        result <- map["result"]
    }
}
