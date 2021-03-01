//
//  FirebaseOperator.swift
//  FBSDKConsumer_Example
//
//  Created by Max Tripilets on 27.06.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging

public class FirebaseOperator {
    var cpConnector: CPConnectionService!
    
    public init(cpConnector: CPConnectionService) {
        self.cpConnector = cpConnector
    }
    
    public func askforregistration(_ application: UIApplication) {
        self.cpConnector.printMsg(message:"fbapp:\(String(describing: FirebaseApp.app())), isfirinc: \(CPMainParameters.shared.isFIRAlreadyInc)")
        if(FirebaseApp.app() == nil && CPMainParameters.shared.isFIRAlreadyInc != "yes"){
            FirebaseApp.configure()
        }

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            let center = UNUserNotificationCenter.current()
            center.delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            center.requestAuthorization(options: authOptions) {
                (granted, error) in
                if !granted {
                    CPMainParameters.shared.notsAllowed = "no"
                    UserDefaults.standard.set(CPMainParameters.shared.notsAllowed,forKey: "notsAllowed")
                    UserDefaults.standard.synchronize()
                    self.cpConnector.postDeniedFCMToCP()
                } else {
                    CPMainParameters.shared.notsAllowed = "yes"
                    UserDefaults.standard.set(CPMainParameters.shared.notsAllowed,forKey: "notsAllowed")
                    UserDefaults.standard.synchronize()
                    _ = self.getRegistrationToken()
                }
                self.cpConnector.printMsg(message: "askforregistration notsAllowed:\(CPMainParameters.shared.notsAllowed)")

            }
            center.getNotificationSettings { (settings) in
                if settings.authorizationStatus != .authorized {
                    CPMainParameters.shared.notsAllowed = "no"
                    UserDefaults.standard.set(CPMainParameters.shared.notsAllowed,forKey: "notsAllowed")
                    UserDefaults.standard.synchronize()
                    //self.postDeniedFCMToCP()
                } else {
                    CPMainParameters.shared.notsAllowed = "yes"
                    UserDefaults.standard.set("yes",forKey: "notsAllowed")
                    UserDefaults.standard.synchronize()
                }
                self.cpConnector.printMsg(message: "askforregistration notsAllowed:\(CPMainParameters.shared.notsAllowed)")
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self as? MessagingDelegate
//        Messaging.messaging().shouldEstablishDirectChannel = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getRefreshedRegistrationToken(notification:)), name: NSNotification.Name.MessagingRegistrationTokenRefreshed, object: nil)
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.MessagingRegistrationTokenRefreshed, object: nil, queue: nil) {_ in
            Messaging.messaging().token {(result,error) in
                if let error = error {
                    self.cpConnector.printMsg(message: "askforregistration error:Error!!!!! fetching remote instance Id: \(error)")
                } else if let result = result {
                    let fcmToken = result
                    self.cpConnector.printMsg(message: "askforregistration fcmToken:\(fcmToken)")

                    self.cpConnector.postFCMTokenToCP(fcmToken:fcmToken)
                } else {
                    self.cpConnector.printMsg(message: "askforregistration error:Error!!!!! Unknown getting fcmToken")
                }
            }
        }
    }
    public func getRegistrationToken() -> String{
        var fcmToken = "";
        Messaging.messaging().token {(result,error) in
            if let error = error {
                self.cpConnector.printMsg(message: "getRegistrationToken error:Error!!!!! fetching remote instance Id: \(error)")
            } else if let result = result {
                fcmToken = result
                self.cpConnector.printMsg(message: "getRegistrationToken fcmToken:\(fcmToken)")
                self.cpConnector.postFCMTokenToCP(fcmToken: fcmToken)
                CPMainParameters.shared.isPushActive = true
            } else {
                self.cpConnector.printMsg(message: "getRegistrationToken error:Error!!!!! Unknown getting fcmToken")
            }
        }
        return fcmToken
    }
    @objc func getRefreshedRegistrationToken(notification: NSNotification){
        Messaging.messaging().token {(result,error) in
            if let error = error {
                self.cpConnector.printMsg(message: "getRefreshedRegistrationToken error:Error!!!!! fetching remote instance Id: \(error)")
            } else if let result = result {
                let fcmToken = result
                
                self.cpConnector.printMsg(message: "getRefreshedRegistrationToken fcmToken:\(fcmToken)")

                self.cpConnector.postFCMTokenToCP(fcmToken:fcmToken)
            } else {
                self.cpConnector.printMsg(message: "getRefreshedRegistrationToken error:Error!!!!! Unknown getting fcmToken")
            }
        }
    }
}
