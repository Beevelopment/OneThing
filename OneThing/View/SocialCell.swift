//
//  SocialCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-15.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class SocialCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: "crown")
        
        return imgView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setupView(imageName: String) {
        backgroundColor = Theme.currentTheme.backgroundColor
        imageView.image = UIImage(named: imageName)
        
        var margin: CGFloat = 0.0
        if let window = UIApplication.shared.keyWindow {
            margin = (window.frame.width - 150) / 6
        }

        addSubview(imageView)
        _ = imageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
