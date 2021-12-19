//
//  HTTPHelper.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 25/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import UIKit

struct HTTPHelper {
    
    //static let SERVER_URL = "https://api.zanibet.com/api/"
    static let SERVER_URL = "http://192.168.1.10:5000/api/"
    static let CLIENT_ID = "XDWUGIXKoNeb727Dne2C5IvowMxLmLjV"
    static let CLIENT_SECRET = "EDTTf780dJ5LcrHQ1BeqOyrUGV07Rh2O"
    
    static func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}
