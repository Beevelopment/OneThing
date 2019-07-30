//
//  PromoCodeModel.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-07-17.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

class PromoCodeModel: NSObject {
    private var _used: String!
    private var _promoCode: String!
    private var _key: String!
    
    var used: String {
        return _used
    }
    var promoCode: String {
        return _promoCode
    }
    var key: String {
        return _key
    }
    
    init(documentData: Dictionary<String, Any>, key: String) {
        if let used = documentData["used"] as? String {
            self._used = used
        }
        if let promoCode = documentData["code"] as? String {
            self._promoCode = promoCode
        }
        
        self._key = key
    }
}

class ActiveCodeUserModel: NSObject {
    private var _activatedDate: String!
    private var _code: String!
    
    var activatedDate: String {
        return _activatedDate
    }
    var code: String {
        return _code
    }
    
    init(documetData: Dictionary<String, Any>) {
        if let activatedDate = documetData["activatedDate"] as? String {
            self._activatedDate = activatedDate
        }
        if let code = documetData["code"] as? String {
            self._code = code
        }
    }
}

class UsedCodeUserModel: NSObject {
    let code: String
    
    init(code: String) {
        self.code = code
    }
}
