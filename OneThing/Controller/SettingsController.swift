//
//  SettingsController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-16.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase
import SafariServices

class SettingsController: UITableViewController {
    
    let settingsCellID = "settingsCellID"
    var settings = ["Setting", "Notification", "Tell Your Story", "Review App", "Report a Bug", "Developer", "Privacy Policy", "Terms & Conditions", "Sign In"]
    
    lazy var messagePopUp: MessagePopUp = {
        let msgPopUp = MessagePopUp()
        msgPopUp.settingsController = self
        
        return msgPopUp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: settingsCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsCellID, for: indexPath) as UITableViewCell
        setupCell(cell: cell, setting: setting)
        return cell
    }
    
    private func setupCell(cell: UITableViewCell, setting: String) {
        cell.textLabel?.textColor = Theme.currentTheme.mainTextColor
        cell.backgroundColor = Theme.currentTheme.backgroundColor
        cell.selectionStyle = .none
        cell.textLabel?.text = setting
        
        if cell.textLabel!.text == "Setting" {
            cell.textLabel?.font = UIFont(name: SansationBold, size: 36)!
        } else {
            cell.textLabel?.font = UIFont(name: SansationRegular, size: 21)!
            cell.accessoryType = .disclosureIndicator
        }
    }
    
    private func reviewApplication() {
        let urlString = "https://apps.apple.com/us/app/onething-extraordinary-result/id1467908953"
        let url = URL(string: urlString)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "action", value: "write-reviwe")
        ]
        
        guard let writeReviweUrl = components?.url else { return }
        UIApplication.shared.open(writeReviweUrl)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let setting = settings[indexPath.row]
        if indexPath.row == 1 {
            UserNotifications.instance.showNotificationAlert { (bool) in
                let notificationController = NotificationController()
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(notificationController, animated: true)
                }
            }
        } else if setting == "Report a Bug" {
            let feecbackController = FeedbackController()
            navigationController?.pushViewController(feecbackController, animated: true)
        } else if setting == "Developer" {
            let developerController = DeveloperController()
            navigationController?.pushViewController(developerController, animated: true)
        } else if setting == "Privacy Policy" {
            guard let url = URL(string: PRIVACY_POLICY) else { return }
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        } else if setting == "Terms & Conditions" {
            guard let url = URL(string: TERMS_CONDITIONS) else { return }
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        } else if setting == "Sign In" {
            let accountController = AccountController()
            present(accountController, animated: true, completion: nil)
        } else if setting == "Upcoming Features" {
            
        } else if setting == "Tell Your Story" {
            let storyController = StoryController()
            navigationController?.pushViewController(storyController, animated: true)
        } else if setting == "Review App" {
            messagePopUp.showNotMarkedMessage(message: .reviweApp, oneThing: "Awesome that you want to give the app a review. If you have found a bug, want to give me or the app feedback please do so in the \"Report a bug\" section. Otherwise, go ahead and review the app!")
        } else if setting == "Enter Promo Code" {
            let promoController = PromoController()
            navigationController?.pushViewController(promoController, animated: true)
        }
    }
}
