//
//  LoadingView.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 24/08/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

protocol LoadingView {
    func showLoadingView()
    func hideLoadingView()
}

extension UIViewController: LoadingView {
    func showLoadingView() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        var indicatorView:NVActivityIndicatorView!
        indicatorView = NVActivityIndicatorView(frame: CGRect(x: (containerView.bounds.width/2)-25, y: (containerView.bounds.height/2)-25, width: 50, height: 50) )
        indicatorView!.type = .ballClipRotateMultiple
        indicatorView!.color = .flatGreen
        containerView.backgroundColor = UIColor.flatGray.withAlphaComponent(0.2)
        containerView.addSubview(indicatorView)
        containerView.tag = 1000
        indicatorView.startAnimating()
        self.view.addSubview(containerView)
    }
    
    func hideLoadingView() {
        self.view.viewWithTag(1000)?.removeFromSuperview()
    }
}
