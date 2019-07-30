//
//  ReadCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-08.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import DeviceKit

class ReadCell: UICollectionViewCell {
    
    let partName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.textColor = .lightGray
        
        return lbl
    }()
    
    let chapterName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 32)!
        lbl.numberOfLines = 0
        
        return lbl
    }()
    
    let chapterSummary: UITextView = {
        let txtView = UITextView()
        txtView.font = UIFont(name: SansationRegular, size: 16)!
        txtView.isEditable = false
        
        return txtView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setupColors() {
        backgroundColor = Theme.currentTheme.backgroundColor
        chapterName.textColor = Theme.currentTheme.mainTextColor
        chapterSummary.textColor = Theme.currentTheme.mainTextColor
        chapterSummary.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    func setupCell(contentModel: ContentModel, part: String) {
        setupColors()
        
        partName.text = part
        chapterName.text = contentModel.title
        chapterSummary.text = contentModel.text
        
        [partName, chapterName, chapterSummary].forEach { addSubview($0) }
        
        if Device.current.isPad {
            let margin = frame.width / 4
            _ = partName.anchor(safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 70, leftConstant: margin, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            _ = chapterName.anchor(partName.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: margin, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
            _ = chapterSummary.anchor(chapterName.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 20, leftConstant: margin, bottomConstant: 25, rightConstant: margin, widthConstant: 0, heightConstant: 0)
        } else {
            _ = partName.anchor(safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 70, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            _ = chapterName.anchor(partName.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
            _ = chapterSummary.anchor(chapterName.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 25, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
