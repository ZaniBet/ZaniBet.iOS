//
//  InviteFriendsController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 20/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import DefaultsKit
import SwiftShareBubbles
import Social

class InviteFriendsController: UIViewController, SwiftShareBubblesDelegate {

    @IBOutlet weak var inviteDescLabel: UILabel!
    @IBOutlet weak var invitationCodeLabel: UILabel!
    @IBOutlet weak var rewardTitleLabel: UILabel!
    @IBOutlet weak var rewardDescLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    let defaults = Defaults()
    var bubbles: SwiftShareBubbles?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inviteDescLabel.text = String.localizedStringWithFormat(NSLocalizedString("invite_friends_desc", comment: ""), User.currentUser.invitationBonus)
        self.invitationCodeLabel.text = User.currentUser.invitationCode
        self.rewardTitleLabel.text = NSLocalizedString("what_you_win", comment: "").uppercased()
        
        self.rewardDescLabel.text = String.localizedStringWithFormat(NSLocalizedString("invite_friends_reward", comment: ""), User.currentUser.coinRewardPercent, User.currentUser.jetonReward)
        self.shareButton.setTitle(NSLocalizedString("share_with_friends", comment: ""), for: UIControlState.normal)
        
        self.bubbles = SwiftShareBubbles(point: CGPoint(x: view.frame.width / 2, y: view.frame.height / 2), radius: 100, in: view)
        self.bubbles?.showBubbleTypes = [Bubble.twitter, Bubble.weibo, Bubble.facebook]
        self.bubbles?.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.shareButton.layer.cornerRadius = 22.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func bubblesTapped(bubbles: SwiftShareBubbles, bubbleId: Int) {
        if let bubble = Bubble(rawValue: bubbleId) {
            //print("\(bubble)")
            switch bubble {
            case .facebook:
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                    guard let composer = SLComposeViewController(forServiceType: SLServiceTypeFacebook) else { return }
                    composer.setInitialText(String.localizedStringWithFormat(NSLocalizedString("invitation_message", comment: ""), User.currentUser.invitationCode))
                    present(composer, animated: true, completion: nil)
                }
                break
            case .twitter:
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                    guard let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else { return }
                    composer.setInitialText(String.localizedStringWithFormat(NSLocalizedString("invitation_message", comment: ""), User.currentUser.invitationCode))
                    present(composer, animated: true, completion: nil)
                }
                break
            case .weibo:
                if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeSinaWeibo) {
                    guard let composer = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo) else { return }
                    composer.setInitialText(String.localizedStringWithFormat(NSLocalizedString("invitation_message", comment: ""), User.currentUser.invitationCode))
                    present(composer, animated: true, completion: nil)
                }
                break
            default:
                break
            }
        } else {
            // custom case
        }
    }
    
    func bubblesDidHide(bubbles: SwiftShareBubbles) {
    }
    
    @IBAction func shareTouched(_ sender: Any) {
        self.bubbles?.show()
    }


}
