//
//  AppDelegate.swift
//  CPSDKiOS
//
//  Created by tomatoset on 02/07/2021.
//  Copyright (c) 2021 tomatoset. All rights reserved.
//

import UIKit
import CPSDKiOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var cpConnector = CPConnectionService(UIApplication.shared)
    var firebaseOperator: FirebaseOperator?
    public var CPToken = "your cp token"
    public var CPGroupName = "your cp group name"
    public var CPName = "your cp name"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        cpConnector.initWithOptions(appscptoken:CPToken, appscpgroup:CPGroupName, appscpname: CPName, doPostCartScreenshot: "", isFIRAlreadyInc: "" )
        
        CPMainParameters.shared.cptoken = "your cp token"
        CPMainParameters.shared.cpSubmitDataEndpoint = "your cp submit data endpoint"
        
        
        firebaseOperator = FirebaseOperator.init(cpConnector: cpConnector)
        firebaseOperator!.askforregistration(application)
        _ = firebaseOperator!.getRegistrationToken()
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        _ = cpConnector.didRecieveNotificationExtensionRequest(userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       print("Unable to register for remote notifications:\(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       _ = firebaseOperator!.getRegistrationToken()
    }


}

