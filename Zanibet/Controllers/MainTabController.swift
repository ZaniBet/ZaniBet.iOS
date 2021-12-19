//
//  MainTabControllerViewController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 30/01/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hidesBottomBarWhenPushed = true
        
        let gameticketStorybard = UIStoryboard(name: "GameTicket", bundle: nil)
        let shopStoryboard = UIStoryboard(name: "Shop", bundle: nil)
        
        // Create Tab one
        let tabOne = gameticketStorybard.instantiateViewController(withIdentifier: "GameTicketController") as! GameTicketPagerController
        let tabOneBarItem = UITabBarItem(title: NSLocalizedString("tab_play", comment: ""), image: UIImage(named: "tab_play"), selectedImage: UIImage(named: "tab_play"))
        tabOne.tabBarItem = tabOneBarItem
        let tabOneNavigation = UINavigationController(rootViewController: tabOne)
        
        // Create Tab two
        let tabTwo = storyboard?.instantiateViewController(withIdentifier: "GrilleGroupController") as! GrilleGroupController
        let tabTwoBarItem = UITabBarItem(title: NSLocalizedString("tab_grilles", comment: ""), image: UIImage(named: "tab_grilles"), selectedImage: UIImage(named: "tab_grilles"))
        tabTwo.tabBarItem = tabTwoBarItem
        let tabTwoNavigation = UINavigationController(rootViewController: tabTwo)
        
        // Create Tab three
        let tabThree = shopStoryboard.instantiateViewController(withIdentifier: "ShopController") as! ShopController
        let tabThreeBarItem = UITabBarItem(title: NSLocalizedString("tab_shop", comment: ""), image: UIImage(named: "tab_reward"), selectedImage: UIImage(named: "tab_reward"))
        tabThree.tabBarItem = tabThreeBarItem
        let tabThreeNavigation = UINavigationController(rootViewController: tabThree)
        
        // Create Tab four
        let tabFour = storyboard?.instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
        let tabFourBarItem = UITabBarItem(title: NSLocalizedString("tab_profile", comment: ""), image: UIImage(named: "tab_profile"), selectedImage: UIImage(named: "tab_profile"))
        tabFour.tabBarItem = tabFourBarItem
        let tabFourNavigation = UINavigationController(rootViewController: tabFour)
        
        self.viewControllers = [tabOneNavigation, tabTwoNavigation, tabThreeNavigation, tabFourNavigation]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // UITabBarControllerDelegate method
    @objc func tabBarController(_ tabBarController: UITabBarController, didSelectdidSelect viewController: UIViewController) {
        print("Selected \(viewController.title!)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
