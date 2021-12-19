//
//  Address.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 30/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import ObjectMapper

class Address: Mappable {
    
    var street:String!
    var zipcode:String!
    var city:String!
    var country:String!

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        street <- map["street"]
        zipcode <- map["zipcode"]
        city <- map["city"]
        country <- map["country"]
    }
    
}
