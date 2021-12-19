//
//  MatchdayTicketPageController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 24/08/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//


import UIKit
import Tabman
import Pageboy
import MoPub
import ChameleonFramework


class MatchdayTicketPageController: TabmanViewController, PageboyViewControllerDataSource {
    
    var gameticket: GameTicket!
    private var viewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("play", comment: "")
        self.automaticallyAdjustsChildViewInsets = true
        self.dataSource = self
        
        // bar customisation
        self.bar.style = .buttonBar
        self.bar.location = .top
        // bar.style = .custom(type: CustomTabmanBar.self) // uncomment to use CustomTabmanBar as style.
        //bar.appearance = PresetAppearanceConfigs.forStyle(self.bar.style, currentAppearance: self.bar.appearance)
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            let colorView: TabmanBar.BackgroundView.Style = TabmanBar.BackgroundView.Style.solid(color: HexColor("#4CAF50")!)
            appearance.style.background = colorView
            appearance.state.color = .flatWhiteDark
            appearance.state.selectedColor = .flatWhite
            
            appearance.indicator.color = .flatWhite
            appearance.indicator.lineWeight = .thin
            appearance.indicator.compresses = true
            appearance.text.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.light)
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private func initializeViewControllers() {
        let gameticketStoryboard = UIStoryboard(name: "GameTicket", bundle: nil)
        var viewControllers = [UIViewController]()
        var barItems = [Item]()
        
        let playMatchdayController = gameticketStoryboard.instantiateViewController(withIdentifier: "PlayTicketController") as! PlayTicketController
        playMatchdayController.gameticket = self.gameticket
        barItems.append(Item(title: "Jouer"))
        viewControllers.append(playMatchdayController)
        

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
