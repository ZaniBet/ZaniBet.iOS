//
//  MoreChipsController.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 18/03/2018.
//  Copyright © 2018 Gromat Luidgi. All rights reserved.
//

import UIKit
import AdscendMedia
import Alamofire
import AlamofireObjectMapper
import UIEmptyState
import AFDateHelper
import ChameleonFramework
import SwiftIcons
import NVActivityIndicatorView
import Imaginary
import Firebase
import ExpandableCell
import KRPullLoader
import SwiftyJSON
import SCLAlertView
import DefaultsKit
import GoogleMobileAds
import MoPub

class MoreChipsController: UIViewController, ADOffersViewControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chipsDescLabel: UILabel!
    @IBOutlet weak var videoChipsLabel: UILabel!
    @IBOutlet weak var videoChipsDescLabel: UILabel!
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDescLabel: UILabel!
    
    @IBOutlet weak var videoChipsButton: UIButton!
    @IBOutlet weak var adscendButton: UIButton!
    
    let defaults = Defaults()
    var indicatorView:NVActivityIndicatorView!
    var bannerView: GADBannerView!
    var adsWatched:Bool = false
    var currentJeton:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("get_more_chips", comment: "")
        
        self.chipsDescLabel.text = NSLocalizedString("chips_task_desc", comment: "")
        
        self.videoChipsLabel.text = String.localizedStringWithFormat(NSLocalizedString("get_n_chips", comment: ""), self.defaults.get(for: Key<Int>("jeton_per_video") )! )
        self.videoChipsDescLabel.text = String.localizedStringWithFormat(NSLocalizedString("video_chips_desc", comment: ""), self.defaults.get(for: Key<Int>("jeton_video_ads_period"))!)
        
        self.taskTitleLabel.text = NSLocalizedString("do_a_task", comment: "")
        self.taskDescLabel.text = NSLocalizedString("task_desc", comment: "")
        
        self.videoChipsButton.setTitle(NSLocalizedString("watch_a_video", comment: ""), for: UIControlState.normal)
        self.adscendButton.setTitle(NSLocalizedString("watch_task", comment: ""), for: UIControlState.normal)
        
        self.currentJeton = User.currentUser.jeton
                
        MPRewardedVideo.loadAd(withAdUnitID: AdsHelper.GET_MORE_CHIPS_ID, keywords: nil, userDataKeywords: User.currentUser.id, location: nil, mediationSettings: nil)
        
        self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: (self.view.bounds.width/2)-25, y: (self.view.bounds.height/2)-89, width: 50, height: 50) )
        self.indicatorView!.type = .ballClipRotateMultiple
        self.indicatorView!.color = .flatGreen
        self.view.addSubview(self.indicatorView!)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MoreChipsController.confirmChips), name: Notification.Name(rawValue: "confirmChips"), object: nil)
        
        bannerView = GADBannerView(adSize: kGADAdSizeMediumRectangle)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bannerView)
        self.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        bannerView.adUnitID = "ca-app-pub-1821217367102526/2523360524"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.videoChipsButton.isEnabled = true
        let alertView = SCLAlertView(appearance:  SCLAlertView.SCLAppearance(
            showCloseButton: false
        ))
        
        if (self.adsWatched){
            self.indicatorView.startAnimating()
            UserService.refreshData {
                self.indicatorView.stopAnimating()
                self.adsWatched = false
                let creditedJeton = User.currentUser.jeton - self.currentJeton
                if (creditedJeton > 0){
                    alertView.addButton(NSLocalizedString("ok", comment: "")) {
                    }
                    alertView.showSuccess("Youha !", subTitle: String.localizedStringWithFormat(NSLocalizedString("chips_added", comment: ""), creditedJeton))
                }
            }
        } else {
            /*alertView.addButton(NSLocalizedString("ok", comment: "")) {
            }
            alertView.showError("Oops", subTitle: NSLocalizedString("err_video_watch_chips", comment: "") )*/
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.videoChipsButton.layer.cornerRadius = 20
        self.adscendButton.layer.cornerRadius = 20
    }
    
    @objc func confirmChips(){
        self.adsWatched = true
    }
    
    @IBAction func videoButtonTouch(_ sender: Any) {
        self.videoChipsButton.isEnabled = false
        self.indicatorView.startAnimating()
        
        if (!MPRewardedVideo.hasAdAvailable(forAdUnitID: AdsHelper.GET_MORE_CHIPS_ID)){
            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_no_ads_available", comment: ""))
            self.videoChipsButton.isEnabled = true
            self.indicatorView.stopAnimating()
            return
        }
        
        self.addMoreJeton(completion: nil)
    }
    
    
    @IBAction func adscendButtonTouch(_ sender: Any) {
        print(User.currentUser.id)
        let offerWall:ADOffersViewController = ADOffersViewController.newOffersWall(forPublisherId: "102589", adwallId: "12910", subId1: User.currentUser.id, delegate: self)
        self.present(offerWall, animated: true, completion: nil)
    }
    
    func onCloseOffersVCPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Créer une demande de crédit de jeton
    func addMoreJeton(completion: (() -> Void)?){
        Alamofire.request(UserRouter.putJeton()).validate().responseJSON {
            response in
            self.indicatorView.stopAnimating()

            switch(response.result){
            case .success(_):
                self.adsWatched = false
                MPRewardedVideo.presentAd(forAdUnitID: AdsHelper.GET_MORE_CHIPS_ID, from: self, with: nil)
                if (completion != nil){
                    completion!()
                }
                break
            case .failure(let error):
                if let err = error as? URLError
                {
                    if (err.code == URLError.Code.notConnectedToInternet){
                        // No internet
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("err_network", comment: ""))
                        }
                    } else if (err.code.rawValue == -1004){
                        // Serveur indisponible
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError(NSLocalizedString("err_title_oups", comment: ""), subTitle: NSLocalizedString("maintenance_mode", comment: ""))
                        }
                    }
                } else {
                    // Other errors
                    if let data = response.data {
                        let json =  JSON(data)
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError("Oups", subTitle: json["detail"].stringValue)
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            SCLAlertView().showError("Oups", subTitle: NSLocalizedString("err_internal", comment: ""))
                        }
                    }
                }
                
                if (completion != nil){
                    completion!()
                }
                break
            }
        }
    }
}
