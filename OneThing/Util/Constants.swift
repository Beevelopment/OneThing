//
//  Constants.swift
//  Freedom
//
//  Created by Carl Henningsson on 2019-04-19.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase

let lightBlue = UIColor(red: 79 / 255, green: 169 / 255, blue: 221 / 255, alpha: 1)
let darkBlue = UIColor(red: 39 / 255, green: 97 / 255, blue: 155 / 255, alpha: 1)
let darkGrey = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.54)
let lightGrey = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.38)
let divider = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.12)
let green = UIColor(red: 79 / 255, green: 221 / 255, blue: 169 / 255, alpha: 1)
let red = UIColor(red: 221 / 255, green: 79 / 255, blue: 79 / 255, alpha: 1)

let SansationLight = "Sansation-Light"
let SansationRegular = "Sansation-Regular"
let SansationBold = "Sansation-Bold"

let clientID = "018a0006e0104163a5128466d39249cf"
let clientSecret = "418363aa4d604d3a81171a259e5ad0f1"
let grantType = "authorization_code"

let tokenType = "bearer"

let appScheme = "Freedom://"

let tinkAuthURL = "https://oauth.tink.com/0.4/authorize/?client_id=\(clientID)&redirect_uri=Freedom://&scope=accounts:read,transactions:read,investments:read,user:read&grant_type=\(grantType)&market=SE&locale=sv_SE"
let tokenURL = "https://api.tink.se/api/v1/oauth/token"
let userAccountsURL = "https://api.tink.se/api/v1/accounts/list"

let userUid = UserDefaults.standard.string(forKey: "uid")
let socialSucurityNumber = UserDefaults.standard.string(forKey: "socialSucurityNumber")

let dataBase = Firestore.firestore()
