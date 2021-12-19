//
//  AppDelegate.swift
//  Zanibet
//
//  Created by Gromat Luidgi on 23/11/2017.
//  Copyright © 2017 Gromat Luidgi. All rights reserved.
//

import UIKit
import KeychainSwift
import ChameleonFramework
import IQKeyboardManagerSwift
import FBSDKCoreKit
import Fabric
import Crashlytics
import Firebase
import UserNotifications
import Alamofire
import AlamofireObjectMapper
import Imaginary
import GoogleMobileAds
import AppLovinSDK
import MoPub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MPRewardedVideoDelegate {

    var window: UIWindow?
    let keychain = KeychainSwift()
    let gcmMessageIDKey = "gcm.message_id"
    let notificationCenter = NotificationCenter.default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initialiser le compteur de jeu
        if (PlaySettings.read() == nil) {
            let settings = PlaySettings(singleCount: 0, matchdayCount: 0)
            settings.write()
        }
        
        // Activer crashlyrics (fabric)
        Fabric.with([Crashlytics.self])
        
        // Activier FireBase
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Activer la gestion automatique du clavier pour les formulaires
        IQKeyboardManager.shared.enable = true

        // Initialiser le médiateur publicitaire
        ALSdk.initializeSdk()
        GADMobileAds.configure(withApplicationID: "ca-app-pub-1821217367102526~4113601142")
        let mopubConfig:MPMoPubConfiguration = MPMoPubConfiguration.init(adUnitIdForAppInitialization: AdsHelper.PLAY_GRID_ID)
        MoPub.sharedInstance().initializeSdk(with: mopubConfig, completion: nil)
        //MoPub.sharedInstance().initializeRewardedVideo(withGlobalMediationSettings: nil, delegate: self, networkInitializationOrder: nil)
        
        // Configurer le theme global de l'application
        configureAppearance()

        // Vérifier si il s'agit de la première ouverture de l'application
        if (AppSettings.read()?.firstOpen == nil) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let launchScreen = mainStoryboard.instantiateViewController(withIdentifier: "OnboardingController") as! OnboardingController
            self.window!.rootViewController = launchScreen
            return true
        }
        
        if (keychain.get("access_token") != nil || FBSDKAccessToken.current() != nil){
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let launchScreen = mainStoryboard.instantiateViewController(withIdentifier: "LoadingController") as! LoadingController
            self.window!.rootViewController = launchScreen
        }
        
        
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    func configureAppearance() {
        let navBarAttributes = [NSAttributedStringKey.foregroundColor: UIColor.clear]
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().barTintColor = HexColor("#4CAF50")
        UINavigationBar.appearance().tintColor = .flatWhite
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.flatWhite, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 18)!]
        
        UIBarButtonItem.appearance().setTitleTextAttributes(navBarAttributes, for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes(navBarAttributes, for: .highlighted)
        
        if #available(iOS 10.0, *) {
            //UITabBar.appearance().unselectedItemTintColor = .lightGray
        }
        //UITabBar.appearance().tintColor = .white
    }
    
    func rewardedVideoAdShouldReward(forAdUnitID adUnitID: String!, reward: MPRewardedVideoReward!) {
        if (adUnitID.contains(AdsHelper.PLAY_GRID_ID)){
            self.notificationCenter.post(name: Notification.Name(rawValue: "confirmMultiGrid"), object: nil)
        } else if (adUnitID.contains(AdsHelper.GET_MORE_CHIPS_ID)){
            self.notificationCenter.post(name: Notification.Name(rawValue: "confirmChips"), object: nil)
        }
    }
    
    func rewardedVideoAdDidFailToPlay(forAdUnitID adUnitID: String!, error: Error!) {
        if (adUnitID.contains(AdsHelper.PLAY_GRID_ID)){
            print(error)
        } else if (adUnitID.contains(AdsHelper.GET_MORE_CHIPS_ID)){

        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        FBSDKAppLinkUtility.fetchDeferredAppLink { (url, err) in
            if (err != nil){
                //print(err!)
            } else {
                //print(url)
            }
        }

    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        Messaging.messaging().subscribe(toTopic: "single_gameticket_today")
        Messaging.messaging().subscribe(toTopic: "topic_global")

        if (keychain.get("access_token") != nil){
            Alamofire.request(CompetitionRouter.getCompetitions())
                .validate()
                .responseArray(completionHandler: { (response: DataResponse<[Competition]>) in
                    if (response.result.isSuccess){
                        if let competitions = response.result.value {
                            for competition:Competition in competitions {
                                let topicName = "topic_open_gameticket_\(competition.id.lowercased())"
                                Messaging.messaging().subscribe(toTopic: topicName)
                            }
                        }
                    }
            })
        }
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}


