//
//   BookModel.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-08.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation

class BookModel {
    private var _maintitle: String!
    private var _subtitle: String?
    private var _index: String!
    private var _content: [ContentModel]!
    
    var maintitle: String {
        return _maintitle
    }
    var subtitle: String {
        return _subtitle ?? ""
    }
    var index: String {
        return _index
    }
    var content: [ContentModel] {
        return _content
    }
    
    var contentArray = [ContentModel]()
    
    init(mainData: Dictionary<String, Any>) {
        if let maintitle = mainData["maintitle"] as? String {
            self._maintitle = maintitle
        }
        if let subtitle = mainData["subtitle"] as? String {
            self._subtitle = subtitle
        }
        if let index = mainData["index"] as? String {
            self._index = index
        }
        if let content = mainData["content"] as? Dictionary<String, AnyObject> {
            contentArray = []
            for cont in content {
                if let values = cont.value as? Dictionary<String, AnyObject> {
                    let key = cont.key
                    let c = ContentModel(contentData: values, key: key)
                    contentArray.append(c)
                }
            }
            self._content = contentArray.sorted(by: { $0.key < $1.key })
        }
    }
}

class ContentModel {
    private var _title: String!
    private var _text: String!
    private var _key: String!
    
    var title: String {
        return _title
    }
    var text: String {
        return _text
    }
    var key: String {
        return _key
    }
    
    init(contentData: Dictionary<String, AnyObject>, key: String) {
        if let title = contentData["title"] as? String {
            self._title = title
        }
        if let text = contentData["text"] as? String {
            let txt = text.replacingOccurrences(of: "\\n", with: "\n")
            self._text = txt
        }
        self._key = key
    }
}
