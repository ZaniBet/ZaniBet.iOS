//
//  LabelHelper.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 01/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    @discardableResult func medium(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "HelveticaNeue-Medium", size: 12)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: "HelveticaNeue-Light", size: 12)!]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
}
