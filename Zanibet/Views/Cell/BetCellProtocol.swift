//
//  BetCellProtocol.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 08/02/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation

protocol BetCellDelegate {
    func onBetSelected(fixtureId:String, selection:Int)
}

protocol SingleBetCellDelegate {
    func onBetSelected(betType:String, selection:Int)
}
