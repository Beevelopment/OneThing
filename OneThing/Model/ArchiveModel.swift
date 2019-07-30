//
//  ArchiveModel.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-05-31.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

class ArchiveModel {
    
    private var _timestamp: String!
    private var _text: String!
    private var _completed: String!
    
    var timestamp: String {
        return _timestamp
    }
    var text: String {
        return _text
    }
    var completed: String {
        return _completed
    }
    
    init(archiveData: Dictionary<String, AnyObject>) {
        if let timestamp = archiveData["timestamp"] as? String {
            self._timestamp = timestamp
        }
        if let text = archiveData["text"] as? String {
            self._text = text
        }
        if let completed = archiveData["completed"] as? String {
            self._completed = completed
        }
    }
}
