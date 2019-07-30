//
//  UserNotifications.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-11.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UserNotifications
import Firebase

class UserNotifications: NSObject {
    
    static let instance = UserNotifications()
    let userNotificationCenter = UNUserNotificationCenter.current()
    let application = UIApplication.shared
    let gcmMessageIDKey = "gcm.message_id"
    let topics: [Topics] = [.all, .day, .week, .month, .quarter, .year, .general]
    
    let dayNotifications: [NotificationModel] = {
        let startDay = NotificationModel(notifyContent:"Don't forget to set your daily OneThing to reach extraordinary results! 🏆", notifyIdentifier: .startDay, schedule: .day)
        let endDay = NotificationModel(notifyContent: "What a great day! Did you also complete your OneThing today? 🏆", notifyIdentifier: .endDay, schedule: .day)
        
        let noti = [startDay, endDay]
        
        return noti
    }()
    
    let weekNotifications: [NotificationModel] = {
        let startWeek = NotificationModel(notifyContent: "New week equals new opportunities, what will be your OneThing this week? 🤔", notifyIdentifier: .startWeek, schedule: .week)
        let endWeek = NotificationModel(notifyContent: "What a magnificent week! Did you also complete your OneThing this week? 🏆", notifyIdentifier: .endWeek, schedule: .week)
        
        let noti = [startWeek, endWeek]
        
        return noti
    }()
    
    func showNotificationAlert(onCompletion: @escaping CompletionHandler) {
        userNotificationCenter.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                self.authorizeNotifications(onCompletion: { (granted) in
                    onCompletion(granted)
                })
            } else if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
            } else if settings.authorizationStatus == .authorized {
                onCompletion(true)
                return
            }
        })
    }

    private func authorizeNotifications(onCompletion: @escaping CompletionHandler) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        userNotificationCenter.requestAuthorization(options: authOptions, completionHandler: {granted, error in
            guard granted else {
                onCompletion(granted)
                return
            }
            DispatchQueue.main.async {
                self.configure(onCompletion: { (bool) in
                    onCompletion(true)
                })
            }
        })
    }
    
    private func configure(onCompletion: @escaping CompletionHandler) {
        userNotificationCenter.delegate = self
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        subscribeUserToTopics { (bool) in
            self.subscribeToLocalNotifications(notifications: self.dayNotifications + self.weekNotifications, onCompletion: { (bool) in
                onCompletion(bool)
            })
        }
    }
    
    func subscribeToLocalNotifications(notifications: [NotificationModel], onCompletion: @escaping CompletionHandler) {
        var dateComponents = DateComponents()
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        for notification in notifications {
            content.body = notification.notifyContent
            content.categoryIdentifier = notification.notifyIdentifier.rawValue
            
            switch notification.schedule {
            case .day:
                if notification.notifyIdentifier == .startDay {
                    dateComponents.hour = 06
                    dateComponents.minute = 30
                } else if notification.notifyIdentifier == .endDay {
                    dateComponents.hour = 19
                    dateComponents.minute = 00
                }
            case .week:
                if notification.notifyIdentifier == .startWeek {
                    dateComponents.weekday = 2
                    dateComponents.hour = 07
                    dateComponents.minute = 00
                } else if notification.notifyIdentifier == .endWeek {
                    dateComponents.weekday = 1
                    dateComponents.hour = 18
                    dateComponents.minute = 30
                }
            default:
                break
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: notification.notifyIdentifier.rawValue, content: content, trigger: trigger)
            userNotificationCenter.add(request)
        }
        onCompletion(true)
    }
    
    private func subscribeUserToTopics(onCompletion: @escaping CompletionHandler) {
        for t in topics {
            let formattedString = t.rawValue.replacingOccurrences(of: " ", with: "")
            Messaging.messaging().subscribe(toTopic: formattedString) { error in
                print("Carl: Subscribed to \(t) topic")
            }
        }
        onCompletion(true)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Carl: Message ID: \(messageID)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Carl: Message ID: \(messageID)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
}

extension UserNotifications: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Carl: Message ID: \(messageID)")
        }
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Carl: Message ID: \(messageID)")
        }
        
        completionHandler()
    }
}

extension UserNotifications: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Carl: Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Carl: Message data", remoteMessage.appData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                print("Carl: Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Carl: Remote instance ID token: \(result.token)")
            }
        })
    }
}
