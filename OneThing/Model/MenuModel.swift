//
//  MenuModel.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-10.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

class MenuModel: NSObject {
    let image: String?
    let titel: String
    
    init(image: String? = nil, titel: String) {
        self.image = image
        self.titel = titel
    }
}

class InAppPurchaseModel: NSObject {
    let priceText: String
    let perMonth: String
    let productID: String
    let priceForIndex: Int?
    
    init(priceText: String, perMonth: String, productID: String, priceForIndex: Int? = nil) {
        self.priceText = priceText
        self.perMonth = perMonth
        self.productID = productID
        self.priceForIndex = priceForIndex
    }
}

class FeaturesModel: NSObject {
    let imageName: String
    let title: String
    
    init(imageName: String, title: String) {
        self.imageName = imageName
        self.title = title
    }
}

class WalktroughModel: NSObject {
    let illustration: String
    let text: String
    let bool: Bool
    
    init(illustration: String, text: String, bool: Bool) {
        self.illustration = illustration
        self.text = text
        self.bool = bool
    }
}
