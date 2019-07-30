//
//  Constants.swift
//  Freedom
//
//  Created by Carl Henningsson on 2019-04-19.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase

let yellow = UIColor(red: 250 / 255, green: 221 / 255, blue: 56 / 255, alpha: 1)
let divider = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
let red = UIColor(red: 250 / 255, green: 56 / 255, blue: 56 / 255, alpha: 1)
let darkModeBackgroundColor = UIColor(red: 48 / 255, green: 48 / 255, blue: 48 / 255, alpha: 1)

let SansationLight = "Sansation-Light"
let SansationRegular = "Sansation-Regular"
let SansationBold = "Sansation-Bold"

let database = Firestore.firestore()
let userUid = UserDefaults.standard.object(forKey: "uid")
let adminUid = "7mPbSTaEPRPKYWFVUOyHzxtrjtF2"

let isRoyalNotificationName = "isRoyalNotificationName"

let TWITTER_CONSUMER_KEY = "7RNe3P1a5W53GFq5ATFFpFoSu"
let TWITTER_CONSUMER_SECRET = "QvkQFLPCB1aC4i7EfVMd3CpnnhLerj9VtzqJicT1lBJ5ezGBYj"

let TERMS_CONDITIONS = "https://www.termsfeed.com/terms-conditions/12681b6e89cc0681eba2b2962fbf6d87"
let PRIVACY_POLICY = "https://www.termsfeed.com/privacy-policy/ad6cdc3c753700374da9a3cbffaf057c"
