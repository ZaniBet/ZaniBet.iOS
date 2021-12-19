//
//  DateHelper.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 01/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
