//
//  FeatureCellTitle.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-07-04.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class FeatureCellTitle: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let title = UILabel()
        title.text = "Features"
        title.font = UIFont(name: SansationBold, size: 32)!
        title.textColor = .white
        
        addSubview(title)
        
        _ = title.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
