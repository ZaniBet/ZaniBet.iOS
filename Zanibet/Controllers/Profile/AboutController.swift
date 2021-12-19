//
//  AboutController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 29/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import SwiftIcons
import StoreKit

class AboutController: UIViewController {
    
    @IBOutlet weak var visitWebsiteButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var visitFacebookButton: UIButton!
    @IBOutlet weak var rateAppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.visitWebsiteButton.setImage(UIImage.init(icon: .fontAwesomeSolid(.globe), size: CGSize(width: 24, height: 24)), for: .normal)
        //self.visitWebsiteButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        
        self.contactButton.setImage(UIImage.init(icon: .fontAwesomeSolid(.envelope), size: CGSize(width: 24, height: 24)), for: .normal)
        //self.contactButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)

        self.visitFacebookButton.setImage(UIImage.init(icon: .fontAwesomeBrands(.facebook), size: CGSize(width: 24, height: 24)), for: .normal)
        //self.visitFacebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)

        self.rateAppButton.setImage(UIImage.init(icon: .fontAwesomeSolid(.star), size: CGSize(width: 24, height: 24)), for: .normal)
        //self.rateAppButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backTouched(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func visitWebsiteTouched(_ sender: Any) {
        guard let url = URL(string: "http://www.zanibet.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func contactTouched(_ sender: Any) {
        guard let url = URL(string: "mailto:contact@zanibet.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    @IBAction func visitFacebookTouched(_ sender: Any) {
        UIApplication.tryURL(urls: [
            "fb://profile/zanibetfoot", // App
            "http://www.facebook.com/zanibetfoot" // Website if app fails
            ])
    }
    
    @IBAction func rateAppTouched(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    
}

extension UIApplication {
    class func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.openURL(URL(string: url)!)
                return
            }
        }
    }
}
