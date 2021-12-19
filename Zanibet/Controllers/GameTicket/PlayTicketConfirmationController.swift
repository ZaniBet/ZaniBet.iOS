//
//  PlayTicketConfirmationController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Alamofire

class PlayTicketConfirmationController: UIViewController {

    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var nbGrilleLabel: UILabel!
    
    
    var gameticket:GameTicket!
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nbGrilleLabel.text = String.localizedStringWithFormat(NSLocalizedString("nb_played_grid", comment: ""), self.gameticket.numberOfGrillePlay!+1, self.gameticket.maxNumberOfPlay!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.replayButton.layer.cornerRadius = 8
        self.replayButton.layer.borderWidth = 0
        
        self.backButton.layer.cornerRadius = 8
        self.backButton.layer.borderWidth = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func replayTouched(_ sender: Any) {
        self.notificationCenter.post(name: Notification.Name(rawValue: "incrementGrillePlay"), object: nil)
        self.dismiss(animated: true, completion: {
        })
    }
    

    @IBAction func backTouched(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            self.notificationCenter.post(name: Notification.Name(rawValue: "popView"), object: nil)
        })
    }


}
