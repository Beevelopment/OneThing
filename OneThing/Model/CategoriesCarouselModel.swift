//
//  CategoriesCarouselModel.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-05-30.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

struct CategoriesCarouselModel {
    let category: String
}

struct NotificationModel {
    let notifyContent: String
    let notifyIdentifier: NotificationIdentifier
    let schedule: Topics
}
