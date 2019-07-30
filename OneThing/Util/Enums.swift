//
//  Enums.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-06.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

enum AnimationName: Int {
    case loading = 0
    case done = 1
    case success = 2
}

enum Message: Int {
    case markedAsDone = 0
    case notMarkedAsDone = 1
    case cancel = 2
    case reviweApp = 3
}

enum Menu: String {
    case walkThrough = "Walkthrough"
    case royalUser = "Royal User"
    case feedback = "Feedback"
    case privacy = "Privacy Policy"
    case shareApp = "Share App"
    case darkMode = "Dark Mode"
    case setting = "Settings"
    case cancel = "Cancel"
}

enum Topics: String {
    case all = "All notifications"
    case day = "Daily reminders"
    case week = "Weekly reminders"
    case month = "Monthly reminders"
    case quarter = "Quarterly reminders"
    case year = "Yearly reminders"
    case general = "General"
}

enum NotificationIdentifier: String {
    case startDay = "startDay"
    case endDay = "endDay"
    case startWeek = "startWeek"
    case endWeek = "endWeek"
}

enum ProviderID: String {
    case facebook = "facebook.com"
    case google = "google.com"
    case twitter = "twitter.com"
    case password = "password"
}

enum PromoError: Error {
    case codeIsActive
    case codeAlreadyUsed
    case codeDoesNotExist
}

extension Menu: CaseIterable {}


