//
//  MainCollectionViewModel.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-05-31.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

class MainCollectionViewModel {
    
    private var _text: String!
    private var _streak: String!
    private var _timestamp: String!
    private var _archive: [ArchiveModel]!
    private var _key: String!
    
    var text: String {
        return _text
    }
    var streak: String {
        return _streak
    }
    var timestamp: String {
        return _timestamp
    }
    var archive: [ArchiveModel] {
        return _archive
    }
    var key: String {
        return _key
    }
    
    var arcArray = [ArchiveModel]()
    
    init(mainData: Dictionary<String, AnyObject>, key: String) {
        if let text = mainData["text"] as? String {
            self._text = text
        }
        if let streak = mainData["streak"] as? String {
            self._streak = streak
        }
        if let timestamp = mainData["timestamp"] as? String {
            self._timestamp = timestamp
        }
        if let archive = mainData["archive"] as? Dictionary<String, AnyObject> {
            arcArray = []
            for arcs in archive {
                if let values = arcs.value as? Dictionary<String, AnyObject> {
                    let arc = ArchiveModel(archiveData: values)
                    arcArray.append(arc)
                }
            }
            self._archive = arcArray
        }
        self._key = key
    }
}
