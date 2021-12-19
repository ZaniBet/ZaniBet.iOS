//
//  OnboardingController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 03/12/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import SwiftyOnboard
import ChameleonFramework

class OnboardingController: UIViewController {

    var swiftyOnboard:SwiftyOnboard!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.swiftyOnboard = SwiftyOnboard(frame: view.frame)
        view.addSubview(self.swiftyOnboard)
        self.swiftyOnboard.style = .light
        self.swiftyOnboard.dataSource = self
        self.swiftyOnboard.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func handleSkip() {
        let appSettings = AppSettings(firstOpen: false)
        appSettings.write()
        
        let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        self.show(loginController, sender: nil)
    }
    
    @objc func handleContinue(sender: UIButton) {
        let index = sender.tag
        self.swiftyOnboard.goToPage(index: index + 1, animated: true)
        if (swiftyOnboard.currentPage == 2){
            let appSettings = AppSettings(firstOpen: false)
            appSettings.write()
            let loginController = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as! LoginController
            self.show(loginController, sender: nil)
        }
    }
}

extension OnboardingController: SwiftyOnboardDataSource, SwiftyOnboardDelegate {
    
    public func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 3
    }
    
    public func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let page = CustomPage.instanceFromNib() as? CustomPage
        page?.title.textColor = UIColor.white
        page?.subTitle.textColor = UIColor.flatWhite
        
        switch(index){
        case 0:
            
            //var imFrame = page.imageView.frame
            //imFrame.origin.y += 40
            //page.imageView.frame = imFrame
            page?.image.image = #imageLiteral(resourceName: "ic_onboarding1")
            page?.titleTabel.text = NSLocalizedString("onboarding1_title", comment: "")
            page?.subTitleLabel.text = NSLocalizedString("onboarding1_content", comment: "")
            //page?.titleTabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            //page?.subTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            break
        case 1:
            page?.image.image = #imageLiteral(resourceName: "ic_onboarding2")
            page?.titleTabel.text = NSLocalizedString("onboarding2_title", comment: "")
            page?.subTitleLabel.text = NSLocalizedString("onboarding2_content", comment: "")
            //page?.titleTabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            //page?.subTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            break
        case 2:
            page?.image.image = #imageLiteral(resourceName: "ic_onboarding3")
            page?.titleTabel.text = NSLocalizedString("onboarding3_title", comment: "")
            page?.subTitleLabel.text = NSLocalizedString("onboarding3_content", comment: "")
            //page?.titleTabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            //page?.subTitleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
            break
        default:
            break
        }
        
        
        return page
    }
    
    public func swiftyOnboardBackgroundColorFor(_ swiftyOnboard: SwiftyOnboard, atIndex index: Int) -> UIColor? {
        return HexColor("#4CAF50")
    }
    
    public func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = SwiftyOnboardOverlay()
        overlay.continueButton.setTitle(NSLocalizedString("continue", comment: ""), for: .normal)
        overlay.continueButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 16)
        overlay.skipButton.addTarget(self, action: #selector(OnboardingController.handleSkip), for: .touchUpInside)
        overlay.continueButton.addTarget(self, action: #selector(OnboardingController.handleContinue), for: .touchUpInside)
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let currentPage = round(position)
        overlay.continueButton.tag = Int(position)
        
        if currentPage == 0.0 || currentPage == 1.0 {
            overlay.continueButton.setTitle(NSLocalizedString("continue", comment: ""), for: .normal)
            overlay.continueButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 16)
            overlay.skipButton.setTitle("Skip", for: .normal)
            overlay.skipButton.isHidden = false
        } else {
            overlay.continueButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Regular", size: 16)
            overlay.continueButton.setTitle("GO!", for: .normal)
            overlay.skipButton.isHidden = true
        }
    }
    
    public func swiftyOnboard(_ swiftyOnboard: SwiftyOnboard, tapped index: Int) {
        //swiftyOnboard.goToPage(index: index, animated: true)
    }
    
    
}
