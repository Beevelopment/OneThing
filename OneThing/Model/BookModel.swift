//
//   BookModel.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-08.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

class Bookmodel {
    private var _maintitle: String!
    private var _subtitle: String!
    
    var maintitle: String {
        return _maintitle
    }
    var subtitle: String {
        return _subtitle
    }
    
    init(mainData: Dictionary<String, AnyObject>) {
        if let maintitle = mainData["maintitle"] as? String {
            self._maintitle = maintitle
        }
        if let subtitle = mainData["subtitle"] as? String {
            self._subtitle = subtitle
        }
    }
}
