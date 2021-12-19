//
//  ReferralController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 20/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class ReferralController: TabmanViewController, PageboyViewControllerDataSource {

    private var viewControllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("share_with_friends", comment: "")

        self.automaticallyAdjustsChildViewInsets = true
        self.dataSource = self
        
        // bar customisation
        self.bar.style = .buttonBar
        self.bar.location = .top
        // bar.style = .custom(type: CustomTabmanBar.self) // uncomment to use CustomTabmanBar as style.
        //bar.appearance = PresetAppearanceConfigs.forStyle(self.bar.style, currentAppearance: self.bar.appearance)
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            
            appearance.indicator.color = .flatGreenDark
            appearance.indicator.lineWeight = .thin
            appearance.indicator.compresses = true
            
            appearance.text.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func initializeViewControllers() {
        let referralStoryboard = UIStoryboard(name: "Referral", bundle: nil)
        var viewControllers = [UIViewController]()
        var barItems = [Item]()
        
        let inviteFriendsController = referralStoryboard.instantiateViewController(withIdentifier: "InviteFriendsController") as! InviteFriendsController
        barItems.append(Item(title: NSLocalizedString("invite", comment: "")))
        viewControllers.append(inviteFriendsController)
        
        let invitedFriendsController = referralStoryboard.instantiateViewController(withIdentifier: "InvitedFriendsController") as! InvitedFriendsController
        barItems.append(Item(title: NSLocalizedString("my_invited", comment: "")))
        viewControllers.append(invitedFriendsController)
        
        bar.items = barItems
        self.viewControllers = viewControllers
    }
    
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        initializeViewControllers()
        return self.viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return self.viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }

}
