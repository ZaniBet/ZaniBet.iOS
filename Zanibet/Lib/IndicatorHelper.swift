//
//  IndicatorHelper.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 02/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

extension NVActivityIndicatorView {

    func provideDefaultIndicator(rect:CGRect) -> NVActivityIndicatorView {
        frame = CGRect(x: (rect.width/2)-25, y: (rect.height/2)-89, width: 50, height: 50)
        type = .ballClipRotateMultiple
        color = .flatGreenDark
        return self
    }
    
}
