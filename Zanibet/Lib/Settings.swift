//
//  AppSettings.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 30/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import Default

struct LoginSettings: Codable, DefaultStorable {
    let lastLogin:String
}

struct AppSettings: Codable, DefaultStorable {
    let firstOpen:Bool
}

struct GameSettings: Codable, DefaultStorable {
    let jetonVideoAdsPeriod:Int
    let jetonPerVideo: Int
    let freeJetonPerDay: Int
    let welcomeZanicoinReward: Int
}
struct PlaySettings: Codable, DefaultStorable {
    let singleCount:Int
    let matchdayCount: Int
}
