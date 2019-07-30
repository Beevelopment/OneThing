//
//  NotificationController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-17.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase

class NotificationController: UITableViewController {
    
    let instance = UserNotifications.instance
    
    let notifications = ["Notifications", Topics.all.rawValue, Topics.day.rawValue, Topics.week.rawValue, Topics.month.rawValue, Topics.quarter.rawValue, Topics.year.rawValue, Topics.general.rawValue, "*Any changes made may take up to 24 hours before fully functional."]

    let notificationsCellID = "notificationsCellID"
    var uid: String!
    var notificationsDict: [String: AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationSubscriptions()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: notificationsCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = Theme.currentTheme.backgroundColor
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = notifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: notificationsCellID, for: indexPath) as UITableViewCell
        setupCell(cell: cell, index: indexPath.row, notification: notification)
        return cell
    }
    
    private func setupCell(cell: UITableViewCell, index: Int, notification: String) {
        cell.textLabel?.textColor = Theme.currentTheme.mainTextColor
        cell.backgroundColor = Theme.currentTheme.backgroundColor
        cell.selectionStyle = .none
        cell.textLabel?.text = notification
        
        if notification == notifications.first! {
            cell.textLabel?.font = UIFont(name: SansationBold, size: 36)!
        } else if notification == notifications.last! {
            cell.textLabel?.font = UIFont(name: SansationLight, size: 14)!
            cell.textLabel?.textColor = divider
            cell.textLabel?.numberOfLines = 0
        } else {
            cell.textLabel?.font = UIFont(name: SansationRegular, size: 21)!
            
            let notificationSwitch = UISwitch(frame: CGRect(x: 1, y: 1, width: 20, height: 20))
            notificationSwitch.addTarget(self, action: #selector(notificationStateChanged), for: .valueChanged)
            notificationSwitch.tag = index
            notificationSwitch.onTintColor = yellow
            
            if let noti = notificationsDict as? [String: String] {
                if noti[notification] == "true" {
                    notificationSwitch.isOn = true
                } else {
                    notificationSwitch.isOn = false
                }
            }
            
            cell.accessoryView = notificationSwitch
        }
    }
    
    private func notificationSubscriptions() {
        
        if !WalkthroughCell.newUser.isEmpty {
            uid = WalkthroughCell.newUser
        } else if let userUid = userUid as? String {
            uid = userUid
        }
        
        database.collection("users").document(uid).getDocument { (documentSnapshot, err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                if let document = documentSnapshot?.data() {
                    for doc in document {
                        if let values = doc.value as? Dictionary<String, AnyObject> {
                            self.notificationsDict = values
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    @objc private func notificationStateChanged(_ sender: UISwitch) {
        let notificationKey = notifications[sender.tag]
        let formattedString = notificationKey.replacingOccurrences(of: " ", with: "")
        if sender.isOn {
            notificationsDict[notificationKey] = "true" as AnyObject
            Messaging.messaging().subscribe(toTopic: formattedString)
            
            if sender.tag == 2 {
                print("Carl: Day")
                instance.subscribeToLocalNotifications(notifications: instance.dayNotifications) { (bool) in
                }
            } else if sender.tag == 3 {
                print("Carl: Week")
                instance.subscribeToLocalNotifications(notifications: instance.weekNotifications) { (bool) in
                }
            }
        } else {
            notificationsDict[notificationKey] = "false" as AnyObject
            Messaging.messaging().unsubscribe(fromTopic: formattedString)
            
            if sender.tag == 2 {
                print("Carl: Day")
                instance.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.startDay.rawValue, NotificationIdentifier.endDay.rawValue])
            } else if sender.tag == 3 {
                print("Carl: Week")
                instance.userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.startWeek.rawValue, NotificationIdentifier.endWeek.rawValue])
            }
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            database.collection("users").document(uid).setData(["notifications": notificationsDict])
        }
    }
}
