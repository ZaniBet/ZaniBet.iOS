//
//  GameTicketController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import MoPub
import ChameleonFramework

class GameTicketPagerController: TabmanViewController, PageboyViewControllerDataSource {
    
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
        
        let helpImage = UIImage.init(icon: .fontAwesomeSolid(.questionCircle), size: CGSize(width: 25, height: 25), textColor: .flatWhite)
        let rightBarButtonItem = UIBarButtonItem.init(image: helpImage, style: .done, target: self, action: #selector(GameTicketPagerController.showRules))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (MoPub.sharedInstance().shouldShowConsentDialog){
            MoPub.sharedInstance().loadConsentDialog(completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showRules(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        //let gameRulesController = mainStoryboard.instantiateViewController(withIdentifier: "GameRulesController") as! GameRulesController
        let helpWebController = mainStoryboard.instantiateViewController(withIdentifier: "HelpWebController") as! HelpWebController
        self.present(helpWebController, animated: true, completion: nil)
    }
    
    private func initializeViewControllers() {
        let gameticketStoryboard = UIStoryboard(name: "GameTicket", bundle: nil)
        var viewControllers = [UIViewController]()
        var barItems = [Item]()
        
        let matchdayGameTicketController = gameticketStoryboard.instantiateViewController(withIdentifier: "MatchdayGameTicketController") as! MatchdayGameTicketController
        barItems.append(Item(title: "MULTI"))
        viewControllers.append(matchdayGameTicketController)
        
       let singleGameTicketController = gameticketStoryboard.instantiateViewController(withIdentifier: "SingleGameTicketController") as! SingleGameTicketController
        barItems.append(Item(title: "SIMPLE"))
        viewControllers.append(singleGameTicketController)
        
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
