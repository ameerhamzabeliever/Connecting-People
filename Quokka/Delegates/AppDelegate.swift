//
//  AppDelegate.swift
//  Quokka
//
//  Created by Muhammad Zubair on 19/11/2020.
//  Copyright © 2020 Codes Binary. All rights reserved.
//

import UIKit
import SCSDKLoginKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setting the Initital View Controller When App is Launch
        if let window = window {
            Helper.setInitialViewController(window: window)
        }
        /// step 1
            FirebaseApp.configure()
        return true
    }
    
    ///step 3
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink){
        guard let url = dynamicLink.url else{
            print("No dynamicLink URL")
            return
        }
        print("Your Incoming link parameters are \(url.absoluteString)")
    }
    
    /// step 2
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL{
            print("Incoming URL link is \(incomingURL)")
            
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamiclink, error) in
                guard error == nil else{
                    print("Error is \(error?.localizedDescription)")
                    return
                }
                if let dynamicLink = dynamiclink{
                    self.handleIncomingDynamicLink(dynamiclink!)
                }
            }
            if linkHandled{
                return true
            }
            else{
                // do other things with incoming url
                return false
            }
        }
        return false
    }
    
    ///step 4
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("I have recieved a url through custom scheme \(url.absoluteString)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        }
        else{
            return SCSDKLoginClient.application(app, open: url, options: options)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
